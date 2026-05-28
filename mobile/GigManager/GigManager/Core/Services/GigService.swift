//
//  GigService.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import Foundation

struct GigService: Sendable {
    
    private let client = APIClient()
    
    func list(token: String) async throws -> [GigResponse] {
        try await client.get("/api/v1/gigs", token: token)
    }
    
    func get(id: UUID, token: String) async throws -> GigResponse {
        try await client.get("/api/v1/gigs/\(id)", token: token)
    }
    
    func create(_ req: CreateGigRequest, token: String) async throws -> GigResponse {
        try await client.post("/api/v1/gigs", body: req, token: token)
    }
    
    func update(id: UUID, _ req: UpdateGigRequest, token: String) async throws -> GigResponse {
        try await client.put("/api/v1/gigs/\(id)", body: req, token: token)
    }
    
    func delete(id: UUID, token: String) async throws {
        try await client.delete("/api/v1/gigs/\(id)", token: token)
    }
    
    func eventTypeSuggestions(token: String) async throws -> [String] {
        try await client.get("/api/v1/gigs/event-type-suggestions", token: token)
    }
}
