//
//  NewGigView.swift
//  GigManager
//
//  Created by Jorge Villeda on 5/29/26.
//

// Sheet form for creating a new gig
import SwiftUI

struct NewGigView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    let viewModel: ScheduleViewModel

    @State private var name = ""
    @State private var date = Date()
    @State private var hasStartTime = false
    @State private var startTime = Date()
    @State private var hasEndTime = false
    @State private var endTime = Date()
    @State private var location = ""
    @State private var type = ""
    @State private var paymentAmount = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

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
                                ForEach(viewModel.eventTypeSuggestions, id: \.self) { suggestion in
                                    Button(suggestion) { type = suggestion }
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
            .navigationTitle("New Gig")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        let req = CreateGigRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            location: location.isEmpty ? nil : location,
            date: Self.dateFormatter.string(from: date),
            startTime: hasStartTime ? Self.timeFormatter.string(from: startTime) : nil,
            endTime: hasEndTime ? Self.timeFormatter.string(from: endTime) : nil,
            type: type.isEmpty ? nil : type,
            paymentAmount: paymentAmount.isEmpty ? nil : Decimal(string: paymentAmount),
            notes: notes.isEmpty ? nil : notes
        )
        do {
            try await viewModel.create(req, using: authVM)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}


#Preview {
    NewGigView(viewModel: ScheduleViewModel())
        .environmentObject(AuthViewModel())
}
