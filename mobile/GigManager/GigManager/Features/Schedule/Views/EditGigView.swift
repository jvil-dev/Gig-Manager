//
//  EditGigView.swift
//  GigManager
//
//  Created by Jorge Villeda on 6/2/26.
//

import SwiftUI

struct EditGigView: View {
    
    @EnvironmentObject
    private var authVM: AuthViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    let viewModel: ScheduleViewModel
    let gig: GigResponse
    let onSave: (GigResponse) -> Void
    
    @State
    private var name: String
    
    @State
    private var date: Date
    
    @State
    private var hasStartTime: Bool
    
    @State
    private var startTime: Date
    
    @State
    private var hasEndTime: Bool
    
    @State
    private var endTime: Date
    
    @State
    private var location: String
    
    @State
    private var type: String
    
    @State
    private var paymentAmount: String
    
    @State
    private var notes: String
    
    @State
    private var isSaving = false
    
    @State
    private var errorMessage: String?
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    init(gig: GigResponse, viewModel: ScheduleViewModel, onSave: @escaping (GigResponse) -> Void) {
        self.gig = gig
        self.viewModel = viewModel
        self.onSave = onSave
        
        let parsedDate = EditGigView.dateFormatter.date(from: gig.date) ?? Date()
        let parsedStart = gig.startTime.flatMap {
            EditGigView.timeFormatter.date(from: $0)
        } ?? Date()
        let parsedEnd = gig.endTime.flatMap {
            EditGigView.timeFormatter.date(from: $0)
        } ?? Date()
        
        _name = State(initialValue: gig.name)
        _date = State(initialValue: parsedDate)
        _hasStartTime = State(initialValue: gig.startTime != nil)
        _startTime = State(initialValue: parsedStart)
        _hasEndTime = State(initialValue: gig.endTime != nil)
        _endTime = State(initialValue: parsedEnd)
        _location = State(initialValue: gig.location ?? "")
        _type = State(initialValue: gig.type ?? "")
        _paymentAmount = State(initialValue: gig.paymentAmount.map { NSDecimalNumber(decimal: $0).stringValue } ?? "")
        _notes = State(initialValue: gig.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Time") {
                    Toggle("Start time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    Toggle("End time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                Section("Optional") {
                    TextField("Location", text: $location)
                    TextField("Event type", text: $type)
                }
                
                if !viewModel.eventTypeSuggestions.isEmpty {
                    Section("Suggestions") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.eventTypeSuggestions, id: \.self) {
                                    suggestion in Button(suggestion) {
                                        type = suggestion
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                Section("Payment") {
                    TextField("Amount", text: $paymentAmount)
                        .keyboardType(.decimalPad)
                    LabeledContent("Status", value: gig.paymentStatus.displayName)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Gig")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await save()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
        }
    }
    
    private func save() async {
        isSaving = true
        errorMessage = nil
        let req = UpdateGigRequest(name: name.trimmingCharacters(in: .whitespaces), location: location.isEmpty ? nil : location, date: Self.dateFormatter.string(from: date), startTime: hasStartTime ? Self.timeFormatter.string(from: startTime) : nil, endTime: hasEndTime ? Self.timeFormatter.string(from: endTime) : nil, type: type.isEmpty ? nil : type, paymentAmount: paymentAmount.isEmpty ? nil : Decimal(string: paymentAmount), notes: notes.isEmpty ? nil : notes)
        
        do {
            try await viewModel.update(id: gig.id, req, using: authVM)
            if let updated = viewModel.gigs.first(where: {
                $0.id == gig.id
            }) {
                onSave(updated)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}

#Preview {
    EditGigView(
        gig: GigResponse(id: UUID(), name: "Preview Gig", location: "Hyla Brook Estate", date: "2026-07-01", startTime: "19:00:00", endTime: "23:00:00", type: "Wedding", paymentAmount: 250, paymentStatus: .unpaid, notes: "Test Blah Blah", createdAt: Date(), updatedAt: Date()),
        viewModel: ScheduleViewModel(),
        onSave: { _ in }
    )
    .environmentObject(AuthViewModel())
}
