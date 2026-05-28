//
//  ClientModels.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import Foundation

struct ClientResponse: Codable, Sendable, Identifiable {
    let id: UUID
    let name: String
    let email: String?
    let phone: String?
    let company: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateClientRequest: Codable, Sendable {
    let name: String
    let email: String?
    let pgone: String?
    let company: String?
    let notes: String?
}

struct UpdateClientRequest: Codable, Sendable {
    let name: String?
    let email: String?
    let phone: String?
    let company: String?
    let notes: String?
}
