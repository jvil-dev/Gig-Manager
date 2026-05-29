//
//  ProfileView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var vm = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let profile = vm.profile {
                    profileContent(profile)
                } else if let error = vm.errorMessage {
                    ContentUnavailableView {
                        Label("Unable to Load Profile", systemImage: "person.slash")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try Again") {
                            Task {
                                await vm.load(using: authVM)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await vm.load(using: authVM)
            }
        }
    }
     @ViewBuilder
    private func profileContent(_ profile: UserProfileResponse) -> some View {
        List {
            Section {
                LabeledContent("Name", value: profile.displayName)
                LabeledContent("Email", value: profile.email)
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        await authVM.signOut()
                    }
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
