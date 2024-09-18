import SwiftUI

struct EditAssignmentView: View {
    @Binding var assignment: Assignment?
    @State private var reminders: [AppReminder] = []

    @Environment(\.presentationMode) var presentationMode  // To control view dismissal
    @EnvironmentObject var appSettings: AppSettings  // Use AppSettings to schedule notifications

    @State private var isShadowNudgeEnabled = false
    @State private var nudgeLevel: Float = 0.5

    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                // Assignment Title
                TextField("Assignment Name", text: Binding(
                    get: { assignment?.title ?? "" },
                    set: { assignment?.title = $0 }
                ))

                // Assignment Description (Multiline TextEditor)
                Section(header: Text("Description")) {
                    TextEditor(text: Binding(
                        get: { assignment?.details ?? "" },
                        set: { assignment?.details = $0 }
                    ))
                    .frame(height: 150)  // Adjust the height as needed
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding()
                    .scrollContentBackground(.hidden)  // Makes the editor scrollable
                }

                // Assignment Due Date
                DatePicker("Due Date", selection: Binding(
                    get: { assignment?.dueDate ?? Date() },
                    set: { assignment?.dueDate = $0 }
                ), displayedComponents: [.date])

                // Debug Information: ShadowNudge Toggle
                Toggle("Enable ShadowNudge", isOn: $isShadowNudgeEnabled)
                    .onAppear {
                        // Initialize ShadowNudge state based on existing assignment data
                        isShadowNudgeEnabled = assignment?.strategySummary != nil
                        print("ShadowNudge Enabled on Load: \(isShadowNudgeEnabled)")
                    }
                    .onChange(of: isShadowNudgeEnabled) { newValue in
                        print("ShadowNudge Toggled: \(newValue)")
                    }

                if isShadowNudgeEnabled {
                    // Nudge level slider
                    Slider(value: $nudgeLevel, in: 0...1)
                    Text("Nudge Level: \(Int(nudgeLevel * 100))%")
                    
                    // Debug Information: Nudge Level Change
                    .onChange(of: nudgeLevel) { newValue in
                        print("Nudge Level Changed to: \(newValue)")
                    }
                }

                // Reminders Section
                Section(header: Text("Reminders")) {
                    ForEach(reminders.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            TextField("Reminder Title", text: $reminders[index].title)
                            DatePicker("Due Date", selection: $reminders[index].dueDate, displayedComponents: [.date])
                        }
                    }
                    Button("Add Reminder") {
                        addReminder()
                        print("Reminder Added")
                    }
                }

                // Debug Information: Save Button
                Button("Save") {
                    print("Save button tapped")
                    saveAssignment()
                    onSave()
                    print("Assignment Saved Successfully")
                    presentationMode.wrappedValue.dismiss()  // Dismiss the view after saving
                }
                .onAppear {
                    if let currentReminders = assignment?.reminders {
                        reminders = currentReminders  // Load existing reminders if they exist
                    }
                }
            }
            .navigationTitle("Edit Assignment")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()  // Dismiss the view on cancel
            })
        }
    }

    private func addReminder() {
        reminders.append(AppReminder(title: "", dueDate: Date(), notes: nil))
    }

    // Debug Information: Save Assignment
    private func saveAssignment() {
        print("Saving Assignment...")
        assignment?.reminders = reminders  // Save reminders back to the assignment

        // ShadowNudge: If enabled, schedule notifications
        if let currentAssignment = assignment {
            if isShadowNudgeEnabled {
                print("Scheduling ShadowNudge for assignment: \(currentAssignment.title)")
                appSettings.scheduleShadowNudgeNotification(for: currentAssignment, nudgeLevel: nudgeLevel)
            } else {
                print("ShadowNudge Disabled, canceling notifications for assignment: \(currentAssignment.title)")
                appSettings.cancelShadowNudgeNotifications(for: currentAssignment)
            }
        } else {
            print("Assignment is nil, nothing to save")
        }
    }
}

struct EditAssignmentView_Previews: PreviewProvider {
    @State static var assignment: Assignment? = Assignment(title: "Sample Assignment", dateAdded: Date(), dueDate: Date().addingTimeInterval(86400), details: "This is a sample assignment description.")

    static var previews: some View {
        EditAssignmentView(assignment: $assignment, onSave: {})
            .environmentObject(AppSettings())  // Ensure AppSettings is injected for the preview
    }
}
