package com.be.service;

import com.be.dto.response.PaymentResponse;
import com.be.enums.PaymentStatus;
import com.be.exception.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentReconciliationService {
    private final PaymentService payments;
    private final SePayOrderClient provider;
    private final ConcurrentHashMap<UUID,Instant> attempts=new ConcurrentHashMap<>();
    // No transaction while waiting for HTTP; existing receipt processor re-locks and validates in its transaction.
    public PaymentResponse reconcile(UUID paymentId, UUID owner) {
        PaymentResponse payment=payments.getPaymentHistory(paymentId,owner);
        if(payment.getStatus()==PaymentStatus.PAID || payment.getStatus()==PaymentStatus.REVIEW_REQUIRED) return payment;
        reserve(paymentId);
        try {
            var receipt=provider.findPaidReceipt(payment.getInvoiceNumber(),owner);
            if(receipt.isPresent()) payments.applyVerifiedReceipt(receipt.get());
            log.info("Payment reconciliation completed paymentId={} providerReceipt={}",paymentId,receipt.isPresent());
            return payments.getPaymentHistory(paymentId,owner);
        } catch(AppException exception) {
            log.warn("Payment reconciliation rejected paymentId={} code={}",paymentId,exception.getErrorCode().getCode());
            throw exception;
        }
    }
    private synchronized void reserve(UUID id) {
        Instant now=Instant.now();attempts.entrySet().removeIf(e->e.getValue().isBefore(now.minusSeconds(30)));
        if(attempts.containsKey(id) || attempts.size()>=1000) throw new AppException(ErrorCode.PAYMENT_RECONCILIATION_BUSY);
        attempts.put(id,now);
    }
}
