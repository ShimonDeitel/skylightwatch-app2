import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: SkylightEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.location)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                    .listRowBackground(Theme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Skylightwatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryRow: View {
    let entry: SkylightEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.location).font(Theme.bodyFont).fontWeight(.semibold)
            Text(entry.lastCheckDate).font(Theme.captionFont).foregroundStyle(.secondary)
            if !entry.notes.isEmpty {
                Text(entry.notes).font(Theme.captionFont).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location: String
    @State private var lastCheckDate: String
    @State private var sealCondition: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private enum Field { case f1, f2, f3, f4 }

    let existing: SkylightEntry?
    let onSave: (SkylightEntry) -> Void

    init(entry: SkylightEntry?, onSave: @escaping (SkylightEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _location = State(initialValue: entry?.location ?? "")
        _lastCheckDate = State(initialValue: entry?.lastCheckDate ?? "")
        _sealCondition = State(initialValue: entry?.sealCondition ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Location", text: $location)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_location")
                    TextField("Lastcheckdate", text: $lastCheckDate)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_lastCheckDate")
                    TextField("Sealcondition", text: $sealCondition)
                        .focused($focusedField, equals: .f3)
                        .accessibilityIdentifier("field_sealCondition")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .f4)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(existing == nil ? "New Skylight" : "Edit Skylight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = SkylightEntry(
                            id: existing?.id ?? UUID(),
                            location: location,
                            lastCheckDate: lastCheckDate,
                            sealCondition: sealCondition,
                            notes: notes,
                            createdAt: existing?.createdAt ?? Date()
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(location.isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
