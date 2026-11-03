package com.be.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

@Configuration
@ConditionalOnProperty(prefix = "sepay.reconciliation", name = "enabled", havingValue = "true", matchIfMissing = true)
public class PaymentReconciliationSchedulingConfig {
    @Bean
    public ThreadPoolTaskScheduler paymentReconciliationTaskScheduler() {
        var scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(1);
        scheduler.setThreadNamePrefix("payment-reconcile-");
        return scheduler;
    }
}
