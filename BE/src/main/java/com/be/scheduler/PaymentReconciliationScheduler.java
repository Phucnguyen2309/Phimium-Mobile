package com.be.scheduler;

import com.be.config.PaymentReconciliationProperties;
import com.be.enums.PaymentStatus;
import com.be.exception.AppException;
import com.be.exception.ErrorCode;
import com.be.repository.PaymentRepository;
import com.be.service.PaymentReconciliationService;
import com.be.util.DateTimeUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(prefix = "sepay.reconciliation", name = "enabled", havingValue = "true", matchIfMissing = true)
public class PaymentReconciliationScheduler {
    private final PaymentRepository payments;
    private final PaymentReconciliationService reconciliation;
    private final PaymentReconciliationProperties properties;

    // HTTP runs on a dedicated thread, outside any DB transaction.
    @Scheduled(scheduler = "paymentReconciliationTaskScheduler",
            fixedDelayString = "${sepay.reconciliation.interval-ms:30000}", initialDelay = 15000)
    public void reconcilePending() {
        if (!properties.isEnabled()) return;
        var now = DateTimeUtils.nowVietnam();
        var dueBefore = now.minusNanos(properties.getIntervalMs() * 1_000_000);
        var candidates = payments.findAutoReconciliationCandidates(PaymentStatus.PENDING,
                now.minusSeconds(15), dueBefore, PageRequest.of(0, properties.getBatchSize()));
        for (var candidate : candidates) {
            try {
                var claimedAt = DateTimeUtils.nowVietnam();
                var claimDueBefore = claimedAt.minusNanos(properties.getIntervalMs() * 1_000_000);
                // An atomic DB claim prevents multiple BE instances from polling this order together.
                if (payments.claimAutoReconciliation(candidate.getId(), PaymentStatus.PENDING,
                        claimedAt, claimDueBefore) != 1) continue;
                var result = reconciliation.reconcile(candidate.getId(), candidate.getOwnerId());
                log.info("Payment auto reconciliation paymentId={} status={}", candidate.getId(), result.getStatus());
            } catch (AppException exception) {
                log.warn("Payment auto reconciliation paymentId={} code={}", candidate.getId(),
                        exception.getErrorCode().getCode());
                // A provider outage stops this batch; the next scheduled round can try again.
                if (exception.getErrorCode() == ErrorCode.PAYMENT_RECONCILIATION_UNAVAILABLE) break;
            } catch (RuntimeException exception) {
                log.warn("Payment auto reconciliation paymentId={} errorType={}", candidate.getId(),
                        exception.getClass().getSimpleName());
                break;
            }
        }
    }
}
