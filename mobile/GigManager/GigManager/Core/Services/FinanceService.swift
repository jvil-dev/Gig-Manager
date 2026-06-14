//
//  FinanceService.swift
//  GigManager
//
//  Created by Jorge Villeda on 6/13/26.
//

import Foundation

struct FinanceService: Sendable {
    
    private let client = APIClient()
    
    func getSummary(token: String) async throws -> FinanceSummaryResponse {
        try await client.get("/api/v1/finance/summary", token: token)
    }
}
