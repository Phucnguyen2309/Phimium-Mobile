package com.be.service;

import com.be.config.SePayProperties;
import com.be.dto.request.SePayWebhookRequest;
import com.be.exception.AppException;
import com.be.exception.ErrorCode;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import java.net.URI;
import java.net.http.HttpClient;
import java.time.Duration;
import java.util.*;

/** Read-only provider calls, never retried automatically. Fail closed on ambiguous data. */
@Component
@lombok.extern.slf4j.Slf4j
public class SePayOrderClient {
    private final SePayProperties properties;
    private final RestClient.Builder builder;
    @Autowired
    public SePayOrderClient(SePayProperties properties) {
        this(properties, RestClient.builder().requestFactory(factory()));
    }
    SePayOrderClient(SePayProperties properties, RestClient.Builder builder) {
        this.properties=properties;this.builder=builder;
    }
    private static JdkClientHttpRequestFactory factory() {
        var factory=new JdkClientHttpRequestFactory(HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(4)).followRedirects(HttpClient.Redirect.NEVER).build());
        factory.setReadTimeout(Duration.ofSeconds(6));return factory;
    }
    public Optional<SePayWebhookRequest> findPaidReceipt(String invoice, UUID customer) {
        String stage="CONFIG";
        String safeInvoice=invoice!=null && invoice.matches("REG_[a-fA-F0-9]{32}")?invoice:"invalid";
        try {
            URI base=URI.create(properties.getApiUrl());
            if (!"https".equals(base.getScheme()) || base.getUserInfo()!=null || base.getQuery()!=null || base.getFragment()!=null
                    || (base.getPort()!=-1 && base.getPort()!=443)
                    || !Set.of("pgapi-sandbox.sepay.vn","pgapi.sepay.vn").contains(base.getHost())
                    || !(base.getPath().isEmpty() || "/".equals(base.getPath()))
                    || properties.getMerchantId()==null || properties.getMerchantId().isBlank()
                    || properties.getSecretKey()==null || properties.getSecretKey().isBlank()) throw unavailable();
            var client=builder.clone().baseUrl(base.toString()).defaultHeaders(h->
                    h.setBasicAuth(properties.getMerchantId(),properties.getSecretKey())).build();
            stage="DETAIL";
            JsonNode detail;
            try {
                detail=client.get().uri("/v1/order/detail/{invoice}",invoice).retrieve().body(JsonNode.class);
            } catch (org.springframework.web.client.HttpClientErrorException.NotFound notFound) {
                log.info("SePay lookup invoice={} result=NOT_FOUND",safeInvoice);
                return Optional.empty();
            }
            JsonNode o=detail==null?null:detail.path("data");
            if(o==null || !invoice.equals(o.path("order_invoice_number").asText())
                    || !customer.toString().equals(o.path("customer_id").asText())) throw unavailable();
            String orderId=o.path("order_id").asText("");
            if(orderId.isBlank()) throw unavailable();
            if(!"CAPTURED".equals(o.path("order_status").asText())) {
                String status=o.path("order_status").asText();
                status=status.matches("[A-Z_]{1,40}")?status:"UNKNOWN";
                log.info("SePay lookup invoice={} result=NOT_CAPTURED providerStatus={}",safeInvoice,status);
                return Optional.empty();
            }
            stage="RECEIPT";
            if(!o.path("transactions").isArray()) throw unavailable();
            var approved=new ArrayList<JsonNode>();
            for(var t:o.path("transactions")) {
                if("APPROVED".equals(t.path("transaction_status").asText())) {
                    if(!"PAYMENT".equals(t.path("transaction_type").asText())) throw unavailable();
                    approved.add(t);
                }
            }
            if(approved.size()!=1) throw unavailable();
            JsonNode t=approved.get(0);
            // REST exposes a transaction UUID as id. Keep it separate from IPN transaction_id.
            String transactionId=t.path("transaction_id").asText("");
            String receiptId=t.path("id").asText("");
            UUID receiptUuid=receiptId.isBlank()?null:UUID.fromString(receiptId);
            if(receiptUuid==null && transactionId.isBlank()) {
                log.warn("SePay lookup invoice={} result=MISSING_RECEIPT_IDENTITY",safeInvoice);
                throw unavailable();
            }
            var request=new SePayWebhookRequest();request.setNotificationType("ORDER_PAID");
            var order=new SePayWebhookRequest.Order(); order.setOrderInvoiceNumber(invoice);order.setOrderId(orderId);
            order.setOrderStatus("CAPTURED");order.setOrderCurrency(o.path("order_currency").asText());
            order.setOrderAmount(new java.math.BigDecimal(o.path("order_amount").asText())); request.setOrder(order);
            var transaction=new SePayWebhookRequest.Transaction();transaction.setId(receiptUuid);
            transaction.setTransactionId(transactionId.isBlank()?null:transactionId);
            transaction.setTransactionType("PAYMENT");transaction.setTransactionStatus("APPROVED");
            transaction.setTransactionCurrency(t.path("transaction_currency").asText());
            transaction.setTransactionAmount(new java.math.BigDecimal(t.path("transaction_amount").asText()));request.setTransaction(transaction);
            log.info("SePay lookup invoice={} result=VERIFIED_RECEIPT",safeInvoice);
            return Optional.of(request);
        } catch(RuntimeException exception) {
            // Log codes only: never the provider message/body or credentials.
            Integer httpStatus=exception instanceof org.springframework.web.client.RestClientResponseException response
                    ?response.getStatusCode().value():null;
            log.warn("SePay lookup invoice={} stage={} result=FAILED httpStatus={} errorType={}",
                    safeInvoice,stage,httpStatus,exception.getClass().getSimpleName());
            throw unavailable();
        }
    }
    private static AppException unavailable(){return new AppException(ErrorCode.PAYMENT_RECONCILIATION_UNAVAILABLE);}
}
