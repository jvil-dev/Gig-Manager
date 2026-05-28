//
//  AuthModels.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

// MARK: - Auth Models
// Codable request/response types matching /api/v1/auth/** DTOs

import Foundation

struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable, Sendable {
    let email: String
    let password: String
    let displayName: String
}

struct RefreshRequest: Encodable, Sendable {
    let refreshToken: String
}

struct LogoutRequest: Encodable, Sendable {
    let refreshToken: String
}

struct AuthResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: UserPayload
    
    struct UserPayload: Decodable, Sendable {
        let id: UUID
        let email: String
        let displayName: String
    }
}
