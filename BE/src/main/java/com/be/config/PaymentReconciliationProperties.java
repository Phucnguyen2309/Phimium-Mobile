package com.be.config;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Component
@ConfigurationProperties(prefix = "sepay.reconciliation")
@Validated
@Data
public class PaymentReconciliationProperties {
    private boolean enabled = true;
    @Min(30000) @Max(3600000)
    private long intervalMs = 30000;
    @Min(1) @Max(5)
    private int batchSize = 5;
}
