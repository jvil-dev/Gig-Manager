//
//  ScheduleViewModel.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/29/26.
//

import Foundation

@Observable
@MainActor
final class ScheduleViewModel {
    
    private static let dateParser: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    private(set) var gigs: [GigResponse] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var eventTypeSuggestions: [String] = []
    
    private let service = GigService()
    
    var groupedGigs: [(key: String, value: [GigResponse])] {
        let sorted = gigs.sorted { $0.date < $1.date }
        let grouped = Dictionary(grouping: sorted) {
            gig -> String in
            guard let date = Self.dateParser.date(from: gig.date)
            else {
                return "Unknown"
            }
            return Self.monthFormatter.string(from: date)
        }
        
        var seen: [String] = []
        var result: [(key: String, value: [GigResponse])] = []
        for gig in sorted {
            guard let date = Self.dateParser.date(from: gig.date) else {
                continue
            }
            let key = Self.monthFormatter.string(from: date)
            if !seen.contains(key) {
                seen.append(key)
                result.append((key: key, value: grouped[key] ?? []))
            }
        }
        return result
    }
    
    func load(using authVM: AuthViewModel) async {
        isLoading = true
        errorMessage = nil
        do {
            let token = try await authVM.validAccessToken()
            async let gigsFetch = service.list(token: token)
            async let suggestionsFetch = service.eventTypeSuggestions(token: token)
            gigs = try await gigsFetch
            eventTypeSuggestions = try await suggestionsFetch
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func create(_ req: CreateGigRequest, using authVM: AuthViewModel) async throws {
        let token = try await authVM.validAccessToken()
        let newGig = try await service.create(req, token: token)
        gigs.append(newGig)
    }
    
    func delete(id: UUID, using authVM: AuthViewModel) async throws {
        let token = try await authVM.validAccessToken()
        try await service.delete(id: id, token: token)
        gigs.removeAll {
            $0.id == id
        }
    }
    
    func update(id: UUID, _ req: UpdateGigRequest, using authVM: AuthViewModel) async throws {
        let token = try await authVM.validAccessToken()
        let updated = try await service.update(id: id, req, token: token)
        if let idx = gigs.firstIndex(where: {
            $0.id == id
        }) {
            gigs[idx] = updated
        }
    }
}
