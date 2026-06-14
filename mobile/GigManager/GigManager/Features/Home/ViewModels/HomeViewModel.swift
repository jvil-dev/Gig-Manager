//
//  HomeViewModel.swift
//  GigManager
//
//  Created by Jorge Villeda on 6/13/26.
//

import Foundation

@Observable
@MainActor
final class HomeViewModel {

    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private(set) var nextGig: GigResponse?
    private(set) var finance: FinanceSummaryResponse?
    private(set) var outstandingGigs: [GigResponse] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let gigService = GigService()
    private let financeService = FinanceService()

    func load(using authVM: AuthViewModel) async {
        isLoading = true
        errorMessage = nil
        do {
            let token = try await authVM.validAccessToken()
            async let gigsFetch = gigService.list(token: token)
            async let financeFetch = financeService.getSummary(token: token)

            let allGigs = try await gigsFetch
            finance = try await financeFetch

            let today = Calendar.current.startOfDay(for: Date())
            let upcoming =
                allGigs
                .filter {
                    guard let date = Self.dateParser.date(from: $0.date) else {
                        return false
                    }
                    return date >= today
                }
                .sorted {
                    $0.date < $1.date
                }

            nextGig = upcoming.first
            outstandingGigs = allGigs.filter {
                $0.paymentStatus == .unpaid || $0.paymentStatus == .depositPaid
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
