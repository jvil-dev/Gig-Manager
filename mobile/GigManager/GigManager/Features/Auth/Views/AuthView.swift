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
        VStack(spacing: 32) {
            branding
            
            VStack(spacing: 16) {
                fields
                errorMessage
                primaryButton
            }
            
            modeToggle
        }
        .padding(24)
    }
    
    private var branding: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Gig Manager")
                .font(.largeTitle)
                .bold()
            Text("Manage your gigs, clients, and income")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var fields: some View {
        if mode == .register {
            styledField {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
            }
        }

        styledField {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
        }
        
        styledField {
            SecureField("Password", text: $password)
                .textContentType(mode == .login ? .password : .newPassword)
        }
    }
    
    @ViewBuilder
    private var errorMessage: some View {
        if let error = authVM.errorMessage {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var primaryButton: some View {
        Button(action: submit) {
            Group {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text(mode == .login ? "Sign In" : "Create Account")
                        .bold()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .disabled(authVM.isLoading)
    }
    
    private var modeToggle: some View {
        Button {
            mode = mode == .login ? .register : .login
            displayName = ""
            authVM.clearError()
        } label: {
            Text(mode == .login ? "No account? Register" : "Have an account? Sign In")
                .font(.subheadline)
        }
    }
    
    private func styledField<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding()
            .background(.quaternary, in: .rect(cornerRadius: 12))
    }
    
    private func submit() {
        Task {
            if mode == .login {
                await authVM.login(email: email, password: password)
            } else {
                await authVM.register(email: email, password: password, displayName: displayName)
            }
        }
    }
}
