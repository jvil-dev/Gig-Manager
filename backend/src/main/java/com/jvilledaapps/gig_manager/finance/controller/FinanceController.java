// REST endpoint for the finance summary
package com.jvilledaapps.gig_manager.finance.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jvilledaapps.gig_manager.finance.dto.FinanceSummaryResponse;
import com.jvilledaapps.gig_manager.finance.service.FinanceSummaryService;

@RestController
@RequestMapping("/api/v1/finance")
public class FinanceController {

    private final FinanceSummaryService financeSummaryService;

    public FinanceController(FinanceSummaryService financeSummaryService) {
        this.financeSummaryService = financeSummaryService;
    }

    @GetMapping("/summary")
    public ResponseEntity<FinanceSummaryResponse> getSummary(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(financeSummaryService.getSummary(userId));
    }

}
