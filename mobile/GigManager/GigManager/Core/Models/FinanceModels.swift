//
//  FinanceModels.swift
//  GigManager
//
//  Created by Jorge Villeda on 6/13/26.
//

import Foundation

struct FinanceSummaryResponse: Decodable, Sendable {
    let totalEarned: Decimal
    let totalOutstanding: Decimal
    let upcomingGigCount: Int
}
