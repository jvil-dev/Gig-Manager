//
//  AuthService.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

// MARK: - Auth Service
// URLSession calls to /api/v1/auth/** Encoder/Decoder created per-call to avoid Sendable issues

import Foundation

struct AuthService: Sendable {
    
    private let base: String

    nonisolated init() {
        self.base = NetworkClient.baseURL
    }
    
    func login(_ req: LoginRequest) async throws -> AuthResponse {
        guard let url = URL(string: base + "/api/v1/auth/login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AuthError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func register(_ req: RegisterRequest) async throws -> AuthResponse {
        guard let url = URL(string: base + "/api/v1/auth/register") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AuthError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func refresh(_ req: RefreshRequest) async throws -> AuthResponse {
        guard let url = URL(string: base + "/api/v1/auth/refresh") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AuthError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func logout(_ req: LogoutRequest) async throws {
        guard let url = URL(string: base + "/api/v1/auth/logout") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(req)
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AuthError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }
    
    enum AuthError: LocalizedError {
        case invalidURL
        case httpError(Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .httpError(401): return "Invalid email or password"
            case .httpError(409): return "Email already taken"
            case .httpError(let code): return "HTTP Error \(code). Try again"
            }
        }
    }
}
