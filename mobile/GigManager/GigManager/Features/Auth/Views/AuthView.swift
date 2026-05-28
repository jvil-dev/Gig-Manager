//
//  AuthView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/27/26.
//

import SwiftUI

struct AuthView: View {
    enum Mode {
        case login, register
    }
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State
    private var mode: Mode = .login
    
    @State
    private var email: String = ""
    
    @State
    private var password: String = ""
    
    @State
    private var displayName: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            if mode == .register {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
            }
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $password)
                .textContentType(mode == .login ? .password : .newPassword)
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            if authVM.isLoading {
                ProgressView()
            } else {
                Button(mode == .login ? "Sign In" : "Register") {
                    Task {
                        if mode == .login {
                            await authVM.login(email: email, password: password)
                        } else {
                            await authVM.register(email: email, password: password, displayName: displayName)
                        }
                    }
                }
            }
            
            Button(mode == .login ? "No account? Register" : "Have an account? Sign in") {
                mode = mode == .login ? .register : .login
                displayName = ""
                authVM.clearError()
            }
            .font(.caption)
        }
        .padding()
    }
}
