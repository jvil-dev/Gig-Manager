//
//  UserService.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import Foundation

struct UserService: Sendable {
    
    private let client = APIClient()
    
    func profile(token: String) async throws -> UserProfileResponse {
        try await client.get("/api/v1/users/me", token: token)
    }
}
