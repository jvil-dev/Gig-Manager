//
//  UserModels.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import Foundation

struct UserProfileResponse: Codable, Sendable, Identifiable {
    let id: UUID
    let email: String
    let displayName: String
    let createdAt: Date
}
