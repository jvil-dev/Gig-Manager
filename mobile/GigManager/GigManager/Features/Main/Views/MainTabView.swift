//
//  MainTabView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

// Root navigation shell for authenticated users
// Houses the four top-level tabs: Home, Schedule, To-Do, and Profile

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Schedule", systemImage: "calendar") {
                ScheduleView()
            }
            Tab("To-Do", systemImage: "checklist") {
                TodoView()
            }
            Tab("Profile", systemImage: "person.circle") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
}

