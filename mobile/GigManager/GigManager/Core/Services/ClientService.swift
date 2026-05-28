//
//  ClientService.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import Foundation

struct ClientService: Sendable {
    
    private let client = APIClient()
    
    func list(token: String) async throws -> [ClientResponse] {
        try await client.get("/api/v1/clients", token: token)
    }
    
    func get(id: UUID, token: String) async throws -> ClientResponse {
              try await client.get("/api/v1/clients/\(id)", token: token)
    }

    func create(_ req: CreateClientRequest, token: String) async throws -> ClientResponse {
        try await client.post("/api/v1/clients", body: req, token: token)
    }

    func update(id: UUID, _ req: UpdateClientRequest, token: String) async throws -> ClientResponse {
        try await client.put("/api/v1/clients/\(id)", body: req, token: token)
    }

    func delete(id: UUID, token: String) async throws {
        try await client.delete("/api/v1/clients/\(id)", token: token)
    }
}
