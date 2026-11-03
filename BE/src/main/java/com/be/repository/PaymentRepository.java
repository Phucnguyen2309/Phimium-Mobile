package com.be.repository;


import com.be.entity.Payment;
import com.be.enums.PaymentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID>, JpaSpecificationExecutor<Payment> {
    interface ReconciliationCandidate {
        UUID getId();
        UUID getOwnerId();
    }

    @Query("""
        select p.id as id, p.registration.user.userId as ownerId from Payment p
        where p.provider = 'SEPAY' and p.status = :status
          and p.createdAt <= :createdBefore
          and (p.lastAutoReconciledAt is null or p.lastAutoReconciledAt <= :dueBefore)
        order by coalesce(p.lastAutoReconciledAt, p.createdAt), p.id
        """)
    List<ReconciliationCandidate> findAutoReconciliationCandidates(
            @Param("status") PaymentStatus status,
            @Param("createdBefore") java.time.LocalDateTime createdBefore,
            @Param("dueBefore") java.time.LocalDateTime dueBefore, Pageable pageable);

    @org.springframework.transaction.annotation.Transactional
    @org.springframework.data.jpa.repository.Modifying
    @Query("""
        update Payment p set p.lastAutoReconciledAt = :now
        where p.id = :id and p.provider = 'SEPAY' and p.status = :status
          and (p.lastAutoReconciledAt is null or p.lastAutoReconciledAt <= :dueBefore)
        """)
    int claimAutoReconciliation(@Param("id") UUID id, @Param("status") PaymentStatus status,
            @Param("now") java.time.LocalDateTime now, @Param("dueBefore") java.time.LocalDateTime dueBefore);

    Optional<Payment> findByInvoiceNumber(String invoiceNumber);

    @org.springframework.data.jpa.repository.Query("select p.registration.registrationId from Payment p where p.invoiceNumber = :invoice")
    Optional<UUID> findRegistrationIdByInvoiceNumber(@org.springframework.data.repository.query.Param("invoice") String invoice);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select p from Payment p where p.invoiceNumber = :invoice")
    Optional<Payment> findByInvoiceNumberWithLock(@org.springframework.data.repository.query.Param("invoice") String invoice);
    List<Payment> findByRegistrationRegistrationId(UUID registrationId);

    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select p from Payment p where p.id = :id")
    Optional<Payment> findByIdWithLock(@org.springframework.data.repository.query.Param("id") UUID id);

    Optional<Payment> findByProviderTransactionId(String providerTransactionId);

    Optional<Payment> findByProviderReceiptId(UUID providerReceiptId);

    Page<Payment> findByRegistrationUserUserId(UUID userId, Pageable pageable);

    Optional<Payment> findByIdAndRegistrationUserUserId(UUID paymentId, UUID userId);

    boolean existsByRegistrationRegistrationIdAndStatus(
            UUID registrationId,
            PaymentStatus status
    );
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = :status")
    BigDecimal sumAmountByStatus(@Param("status") PaymentStatus status);
}
