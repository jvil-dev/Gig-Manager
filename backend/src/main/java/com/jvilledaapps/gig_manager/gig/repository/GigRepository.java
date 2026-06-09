// Data access for gigs - all queries scoped to the owning user
package com.jvilledaapps.gig_manager.gig.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.jvilledaapps.gig_manager.gig.model.Gig;
import com.jvilledaapps.gig_manager.gig.model.PaymentStatus;

public interface GigRepository extends JpaRepository<Gig, UUID> {

    List<Gig> findByUserIdOrderByDateDesc(UUID userId);

    Optional<Gig> findByIdAndUserId(UUID id, UUID userId);

    void deleteByIdAndUserId(UUID id, UUID userId);

    @Query("SELECT g.type FROM Gig g WHERE g.userId = :userId AND g.type IS NOT NULL GROUP BY g.type ORDER BY MAX(g.date) DESC")
    List<String> findDistinctTypesByUserId(@Param("userId") UUID userId);

    @Query("SELECT SUM(g.paymentAmount) FROM Gig g WHERE g.userId = :userId AND g.paymentStatus = :status")
    BigDecimal sumByUserIdAndStatus(@Param("userId") UUID userId, @Param("status") PaymentStatus status);

    @Query("SELECT SUM(g.paymentAmount) FROM Gig g WHERE g.userId = :userId AND g.paymentStatus <> :status")
    BigDecimal sumByUserIdAndStatusNot(@Param("userId") UUID userId, @Param("status") PaymentStatus status);

    @Query("SELECT COUNT(g) FROM Gig g WHERE g.userId = :userId AND g.date >= CURRENT_DATE")
    long countUpcomingByUserId(@Param("userId") UUID userId);

}
