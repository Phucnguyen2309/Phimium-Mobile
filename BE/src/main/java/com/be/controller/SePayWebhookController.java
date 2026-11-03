package com.be.controller;

import com.be.dto.request.SePayWebhookRequest;
import com.be.dto.response.ApiResponse;
import com.be.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@lombok.extern.slf4j.Slf4j
@RestController
@RequestMapping("/api/webhooks/sepay")
public class SePayWebhookController {
    @Autowired
    PaymentService paymentService;

    @PostMapping
    public ResponseEntity<ApiResponse<?>> handleWebhook(@jakarta.validation.Valid @RequestBody SePayWebhookRequest request,
            @RequestHeader(value = "X-Secret-Key", required = false) String secret){
        String invoice=request.getOrder()==null?"missing":request.getOrder().getOrderInvoiceNumber();
        invoice=invoice!=null && invoice.matches("REG_[a-fA-F0-9]{32}")?invoice:"invalid";
        try {
            paymentService.processPayment(request, secret);
            log.info("SePay IPN processed invoice={}",invoice);
        } catch(com.be.exception.AppException exception) {
            log.warn("SePay IPN rejected invoice={} code={}",invoice,exception.getErrorCode().getCode());
            throw exception;
        }
        return ResponseEntity.ok(ApiResponse.success("Payment processed successfully",null));
    }
}
