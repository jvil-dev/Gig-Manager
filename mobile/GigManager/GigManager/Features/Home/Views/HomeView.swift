//
//  HomeView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/28/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject
    private var authVM: AuthViewModel

    @State
    private var vm = HomeViewModel()

    @State
    private var scheduleVM = ScheduleViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let error = vm.errorMessage {
                    ContentUnavailableView {
                        Label(
                            "Unable to Load",
                            systemImage: "exclamationmark.triangle"
                        )
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Try again") {
                            Task {
                                await vm.load(using: authVM)
                            }
                        }
                    }
                } else {
                    dashboard
                }
            }
            .navigationTitle("Home")
            .task {
                await vm.load(using: authVM)
            }
        }
    }

    private var dashboard: some View {
        List {
            Section("Next Gig") {
                if let gig = vm.nextGig {
                    NavigationLink {
                        GigDetailView(gig: gig, viewModel: scheduleVM)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(gig.name)
                                .font(.headline)
                            Text(formattedDate(gig.date))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("No upcoming gigs")
                        .foregroundStyle(.secondary)
                }
            }

            if let finance = vm.finance {
                Section("Finance") {
                    LabeledContent("Total earned") {
                        Text(
                            finance.totalEarned,
                            format: .currency(code: "USD")
                        )
                    }
                    LabeledContent("Upcoming gigs") {
                        Text(finance.upcomingGigCount, format: .number)
                    }
                }
            }

            Section("Outstanding") {
                if vm.outstandingGigs.isEmpty {
                    Text("No outstanding payments")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(vm.outstandingGigs) { gig in
                        LabeledContent(gig.name) {
                            Text(
                                gig.paymentAmount ?? 0,
                                format: .currency(code: "USD")
                            )
                        }
                    }
                }
            }
            .refreshable {
                await vm.load(using: authVM)
            }
        }
    }

    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private func formattedDate(_ raw: String) -> String {
        guard let date = Self.dateParser.date(from: raw)
        else {
            return raw
        }
        return date.formatted(date: .long, time: .omitted)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
