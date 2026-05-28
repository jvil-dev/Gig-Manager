//
//  ContentView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/26/26.
//

// MARK: - Content View
//
// Root view. Routes between AuthView and app content

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        if authVM.currentUser == nil {
            AuthView()
        } else {
            SignedInView()
        }
    }
}
