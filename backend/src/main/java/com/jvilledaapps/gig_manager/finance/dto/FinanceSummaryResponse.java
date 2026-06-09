// Response payload for the finance summary widget
package com.jvilledaapps.gig_manager.finance.dto;

import java.math.BigDecimal;

public record FinanceSummaryResponse(BigDecimal totalEarned, BigDecimal totalOutstanding, long upcomingGigCount) {

}
