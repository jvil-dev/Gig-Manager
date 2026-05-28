//
//  GigManagerApp.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/26/26.
//

// MARK: - Gig Manager App
//
// App entry point. Creates AuthViewModel once and injects it into the environment.
// This also restores any persisted Keychain session on launch
//
// Dependencies: - AuthViewModel: Auth state and token lifecycle

import SwiftUI

@main
struct GigManagerApp: App {
    
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .task { authVM.restoreSession() }
        }
    }
}
