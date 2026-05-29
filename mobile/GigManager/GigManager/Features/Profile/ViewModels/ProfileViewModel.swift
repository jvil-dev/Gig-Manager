//
//  ProfileViewModel.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    
    private(set) var profile: UserProfileResponse?
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    
    private let service = UserService()
    
    func load(using authVM: AuthViewModel) async {
        isLoading = true
        errorMessage = nil
        do {
            let token = try await authVM.validAccessToken()
            profile = try await service.profile(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
