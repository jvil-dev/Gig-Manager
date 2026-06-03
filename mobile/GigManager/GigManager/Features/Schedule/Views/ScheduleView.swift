//
//  ScheduleView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var vm = ScheduleViewModel()
    @State private var showNewGig = false
    @State private var deleteError: String?

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let error = vm.errorMessage {
                    ContentUnavailableView {
                        Label("Unable to Load Schedule", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try Again") {
                            Task { await vm.load(using: authVM) }
                        }
                    }
                } else if vm.gigs.isEmpty {
                    ContentUnavailableView(
                        "No Gigs Yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Tap + to add your first gig.")
                    )
                } else {
                    gigList
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNewGig = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewGig) {
                NewGigView(viewModel: vm)
            }
            .task { await vm.load(using: authVM) }
            .alert("Error", isPresented: Binding(
                get: { deleteError != nil },
                set: { if !$0 { deleteError = nil } }
            )) {
                Button("OK") { deleteError = nil }
            } message: {
                Text(deleteError ?? "")
            }
        }
    }

    private var gigList: some View {
        List {
            ForEach(vm.groupedGigs, id: \.key) { group in
                Section(group.key) {
                    ForEach(group.value) {
                        gig in
                        NavigationLink {
                            GigDetailView(gig: gig, viewModel: vm)
                        } label: {
                            GigRow(gig: gig)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                do {
                                    try await vm.delete(id: group.value[index].id, using: authVM)
                                } catch {
                                    deleteError = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct GigRow: View {
    let gig: GigResponse

    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private static let timeParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let timeDisplay: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            datePill
            VStack(alignment: .leading, spacing: 2) {
                Text(gig.name)
                if let type = gig.type {
                    Text(type)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let start = gig.startTime, let date = Self.timeParser.date(from: start) {
                Text(Self.timeDisplay.string(from: date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var datePill: some View {
        if let date = Self.dateParser.date(from: gig.date) {
            VStack(spacing: 2) {
                Text(Self.dayFormatter.string(from: date).uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.title3.bold())
            }
            .frame(width: 40)
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(AuthViewModel())
}
