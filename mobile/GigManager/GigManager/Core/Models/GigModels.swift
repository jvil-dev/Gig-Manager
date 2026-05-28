//
//  GigModels.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import Foundation

enum PaymentStatus: String, Codable, CaseIterable, Sendable {
    case unpaid = "UNPAID"
    case depositPaid = "DEPOSIT_PAID"
    case paid = "PAID"
}

struct GigResponse: Codable, Sendable, Identifiable {
    let id: UUID
    let name: String
    let location: String?
    let date: String
    let startTime: String?
    let endTime: String?
    let type: String?
    let paymentAmount: Decimal?
    let paymentStatus: PaymentStatus
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateGigRequest: Codable, Sendable {
    let name: String
    let location: String?
    let date: String
    let startTime: String?
    let endTime: String?
    let type: String?
    let paymentAmount: Decimal?
    let notes: String?
}

struct UpdateGigRequest: Codable, Sendable {
    let name: String
    let location: String?
    let date: String
    let startTime: String?
    let endTime: String?
    let type: String?
    let paymentAmount: Decimal?
    let notes: String?
}
