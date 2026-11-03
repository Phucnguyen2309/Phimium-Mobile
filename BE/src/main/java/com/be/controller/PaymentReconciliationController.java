package com.be.controller;

import com.be.dto.response.*;
import com.be.entity.User;
import com.be.service.PaymentReconciliationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/payment")
public class PaymentReconciliationController {
    private final PaymentReconciliationService reconciliation;
    @PostMapping("/{paymentId}/reconcile")
    public ApiResponse<PaymentResponse> reconcile(@PathVariable UUID paymentId,@AuthenticationPrincipal User owner) {
        return ApiResponse.success("Payment status checked with provider",reconciliation.reconcile(paymentId,owner.getUserId()));
    }
}
