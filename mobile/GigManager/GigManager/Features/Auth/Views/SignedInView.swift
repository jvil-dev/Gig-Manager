//
//  SignedInView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import SwiftUI

struct SignedInView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Signed In as \(authVM.currentUser?.email ?? "")")
            
            if authVM.isLoading {
                ProgressView()
            } else {
                Button("Sign out") {
                    Task {
                        await authVM.signOut()
                    }
                }
            }
        }
    }
}
