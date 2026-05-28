//
//  AuthViewModel.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

// MARK: - Auth View Model

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published private(set) var currentUser: AuthResponse.UserPayload?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    
    private let service: AuthService
    
    nonisolated init(service: AuthService = AuthService()) {
        self.service = service
    }
    
    func register(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await service.register(RegisterRequest(email: email, password: password, displayName: displayName))
            saveSession(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func restoreSession() {
        guard
            let token = KeychainManager.load(for: "gm.accessToken"),
            let idStr = KeychainManager.load(for: "gm.userID"),
            let id = UUID(uuidString: idStr),
            let email = KeychainManager.load(for: "gm.userEmail"),
            let displayName = KeychainManager.load(for: "gm.displayName"),
            !token.isEmpty
        else {
            return
        }
        currentUser = AuthResponse.UserPayload(id: id, email: email, displayName: displayName)
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await service.login(LoginRequest(email: email, password: password))
            saveSession(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signOut() async {
        let refreshToken = KeychainManager.load(for: "gm.refreshToken") ?? ""
        if !refreshToken.isEmpty {
            try? await service.logout(LogoutRequest(refreshToken: refreshToken))
        }
        clearSession()
    }
    
    func validAccessToken() async throws -> String {
        guard
            let expiryStr = KeychainManager.load(for: "gm.tokenExpiry"),
            let expiry = try? Date(expiryStr, strategy: .iso8601),
            let refresh = KeychainManager.load(for: "gm.refreshToken")
        else {
            throw TokenError.noSession
        }
        
        if expiry > Date.now.addingTimeInterval(60) {
            guard let token = KeychainManager.load(for: "gm.accessToken")
            else {
                throw TokenError.noSession
            }
            return token
        }
        
        let response = try await service.refresh(RefreshRequest(refreshToken: refresh))
        saveSession(response)
        return response.accessToken
    }
    
    private func saveSession(_ response: AuthResponse) {
        let expiry = Date.now.addingTimeInterval(15 * 60)
        try? KeychainManager.save(response.accessToken,        for: "gm.accessToken")
        try? KeychainManager.save(response.refreshToken,       for: "gm.refreshToken")
        try? KeychainManager.save(expiry.formatted(.iso8601),  for: "gm.tokenExpiry")
        try? KeychainManager.save(response.user.id.uuidString, for: "gm.userID")
        try? KeychainManager.save(response.user.email,         for: "gm.userEmail")
        try? KeychainManager.save(response.user.displayName,   for: "gm.displayName")
        currentUser = response.user
    }
    
    private func clearSession() {
        ["gm.accessToken", "gm.refreshToken", "gm.tokenExpiry", "gm.userID", "gm.userEmail", "gm.displayName"].forEach {
            KeychainManager.delete(for: $0)
        }
        currentUser = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    enum TokenError: Error {
        case noSession
    }
}
