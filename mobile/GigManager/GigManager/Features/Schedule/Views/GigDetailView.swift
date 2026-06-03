//
//  GigDetailView.swift
//  GigManager
//
//  Created by Jorge Villeda on 6/1/26.
//

import SwiftUI
import MapKit

struct GigDetailView: View {
    @EnvironmentObject
    private var authVM: AuthViewModel
    let viewModel: ScheduleViewModel
    
    @State
    private var gig: GigResponse
    
    @State
    private var showEdit = false
    
    @State
    private var foundItem: MKMapItem?
    private var coordinate: CLLocationCoordinate2D? {
        foundItem?.location.coordinate
    }
    
    @State
    private var mapPosition: MapCameraPosition = .automatic
    
    @State
    private var geocodeFailed = false
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private static let dateDisplay: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        return f
    }()
    
    private static let timeFormatter: DateFormatter = {
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
    
    init(gig: GigResponse, viewModel: ScheduleViewModel) {
        _gig = State(initialValue: gig)
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Name", value: gig.name)
                LabeledContent("Date", value: formattedDate)
                if let timeRange = formattedTimeRange {
                    LabeledContent("Time", value: timeRange)
                }
                if let type = gig.type {
                    LabeledContent("Type", value: type)
                }
            }
            
            if let location = gig.location {
                Section("Location") {
                    Text(location)
                    if let coord = coordinate {
                        Map(position: $mapPosition) {
                            Marker(gig.name, coordinate: coord)
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .listRowInsets(EdgeInsets())
                        .allowsHitTesting(false)
                        Button("Open in Maps") {
                            foundItem?.openInMaps()
                        }
                    } else if geocodeFailed {
                        Text("Map unavailable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Section("Payment") {
                if let formatted = formattedAmount {
                    LabeledContent("Amount", value: formatted)
                }
                LabeledContent("Status", value: gig.paymentStatus.displayName)
            }
            
            if let notes = gig.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }
        }
        .navigationTitle(gig.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEdit = true
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditGigView(gig: gig, viewModel: viewModel) {
                updated in gig = updated
            }
        }
        .task {
            await geocode()
        }
    }
    
    private var formattedDate: String {
        guard let date = Self.dateFormatter.date(from: gig.date)
        else {
            return gig.date
        }
        return Self.dateDisplay.string(from: date)
    }
    
    private var formattedTimeRange: String? {
        guard let start = gig.startTime,
              let startDate = Self.timeFormatter.date(from: start)
        else {
            return nil
        }
        let startStr = Self.timeDisplay.string(from: startDate)
        guard let end = gig.endTime,
              let endDate = Self.timeFormatter.date(from: end)
        else {
            return startStr
        }
        return "\(startStr) - \(Self.timeDisplay.string(from: endDate))"
    }
    
    private var formattedAmount: String? {
        guard let amount = gig.paymentAmount else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSDecimalNumber(decimal: amount))
    }
    
    private func geocode() async {
        guard let location = gig.location, !location.isEmpty else {
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        do {
            let response = try await MKLocalSearch(request: request).start()
            if let item = response.mapItems.first {
                let coord = item.location.coordinate
                foundItem = item
                mapPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            } else {
                geocodeFailed = true
            }
        } catch {
            geocodeFailed = true
        }
    }
}

#Preview {
    NavigationStack {
        GigDetailView(gig: GigResponse(
            id: UUID(),
            name: "Test",
            location: "Hyla Brook Estate",
            date: "2026-07-01",
            startTime: "19:00:00",
            endTime: "23:00:00",
            type: "Baby Shower",
            paymentAmount: 250,
            paymentStatus: .unpaid,
            notes: "Remember to check mic batteries",
            createdAt: Date(),
            updatedAt: Date()
            ),
                      viewModel: ScheduleViewModel()
                      )
        .environmentObject(AuthViewModel())
    }
}
