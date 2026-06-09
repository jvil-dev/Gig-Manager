// Derives all-time finance totals from the gigs table for the authenticated user
package com.jvilledaapps.gig_manager.finance.service;

import java.math.BigDecimal;
import java.util.Objects;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.jvilledaapps.gig_manager.finance.dto.FinanceSummaryResponse;
import com.jvilledaapps.gig_manager.gig.model.PaymentStatus;
import com.jvilledaapps.gig_manager.gig.repository.GigRepository;

@Service
public class FinanceSummaryService {

    private final GigRepository gigRepository;

    public FinanceSummaryService(GigRepository gigRepository) {
        this.gigRepository = gigRepository;
    }

    public FinanceSummaryResponse getSummary(UUID userId) {
        BigDecimal earned = Objects.requireNonNullElse(gigRepository.sumByUserIdAndStatus(userId,
                PaymentStatus.PAID),
                BigDecimal.ZERO);
        BigDecimal outstanding = Objects
                .requireNonNullElse(gigRepository.sumByUserIdAndStatusNot(userId,
                        PaymentStatus.PAID), BigDecimal.ZERO);
        long upcoming = gigRepository.countUpcomingByUserId(userId);
        return new FinanceSummaryResponse(earned, outstanding, upcoming);
    }

}