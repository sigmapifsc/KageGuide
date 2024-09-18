import SwiftUI
import Foundation

struct AddAssignmentView: View {
    @Binding var assignmentTitle: String
    @Binding var assignmentDescription: String
    @Binding var dueDate: Date
    @Binding var reminders: [AppReminder]
    
    @State private var isShadowNudgeEnabled = false
    @State private var nudgeLevel: Float = 0.5

    @Environment(\.presentationMode) var presentationMode
    var onSave: (String?) -> Void  // Pass the event identifier back to the caller
    var calendarManager: CalendarManager
    var schoolCalendarName: String  // Pass the school calendar name

    @State private var reminderTitle: String = ""
    @State private var reminderDueDate: Date = Date()
    @State private var showReminderFields = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Assignment Name", text: $assignmentTitle)

                // Change to TextEditor for multiline text input
                TextEditor(text: $assignmentDescription)
                    .frame(height: 150)  // Adjust as necessary
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding()
                    .scrollContentBackground(.hidden)  // Makes the editor scrollable

                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])

                // ShadowNudge toggle
                Toggle("Enable ShadowNudge", isOn: $isShadowNudgeEnabled)

                if isShadowNudgeEnabled {
                    // Nudge level slider
                    Slider(value: $nudgeLevel, in: 0...1)
                    Text("Nudge Level: \(Int(nudgeLevel * 100))%")
                }
                
                Toggle("Set Reminders", isOn: $showReminderFields.animation())
                    .onChange(of: showReminderFields) { isOn in
                        if isOn && reminderTitle.isEmpty {
                            // Auto-populate the reminder title with the assignment title when the toggle is turned on
                            reminderTitle = assignmentTitle
                        }
                    }

                if showReminderFields {
                    TextField("Reminder Title", text: $reminderTitle)  // Auto-populated but editable
                    DatePicker("Reminder Date & Time", selection: $reminderDueDate, displayedComponents: [.date, .hourAndMinute])

                    Button("Add Reminder") {
                        let newReminder = AppReminder(title: reminderTitle, dueDate: reminderDueDate, notes: assignmentDescription)
                        reminders.append(newReminder)
                        print("Reminder Added: \(reminderTitle) for \(reminderDueDate)")
                        reminderTitle = ""
                        reminderDueDate = Date()
                    }
                    .disabled(reminderTitle.isEmpty)
                }

                List {
                    ForEach(reminders) { reminder in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reminder.title).font(.headline)
                                Text("Due: \(reminder.dueDate, formatter: dateFormatter)").font(.subheadline)
                            }
                            Spacer()
                            Button(action: { deleteReminder(reminder) }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            deleteReminder(reminders[index])
                        }
                    }
                }

                Button("Save Assignment") {
                    print("Save button tapped")
                    print("Assignment Title: \(assignmentTitle)")
                    print("Assignment Description: \(assignmentDescription)")
                    print("Due Date: \(dueDate)")

                    // Add the assignment to the system calendar as an event
                    let eventIdentifier = calendarManager.addOrUpdateEvent(
                        title: assignmentTitle,
                        dueDate: dueDate,
                        notes: assignmentDescription,
                        toCalendarWithName: schoolCalendarName,
                        eventIdentifier: nil
                    )
                    if let eventID = eventIdentifier {
                        print("Event successfully saved with ID: \(eventID)")
                    } else {
                        print("Failed to save event")
                    }

                    // Add each reminder to the system's reminders app
                    for reminder in reminders {
                        calendarManager.addReminder(title: reminder.title, dueDate: reminder.dueDate, notes: reminder.notes)
                        print("Reminder saved: \(reminder.title) - Due: \(reminder.dueDate)")
                    }

                    // ShadowNudge: Only activate if enabled
                    if isShadowNudgeEnabled {
                        let shadowNudgeAssignment = ShadowNudgeAssignment()

                        // Calculate days left until due date using the helper function
                        let daysLeft = daysLeftAsInt(until: dueDate)
                        
                        // Assuming newAssignment is defined based on current form data
                        let newAssignment = Assignment(
                            id: UUID(),  // Generate a new UUID for the assignment
                            title: assignmentTitle,
                            dateAdded: Date(),  // Use the current date for when the assignment is added
                            dueDate: dueDate,
                            details: assignmentDescription,
                            reminders: reminders,
                            eventIdentifier: eventIdentifier,  // Use event identifier if available
                            strategySummary: nil  // This can be updated later if necessary
                        )
                        shadowNudgeAssignment.activateNudge(for: newAssignment, daysLeft: daysLeft, nudgeLevel: nudgeLevel)
                    }

                    onSave(eventIdentifier)  // Save the assignment within the app's data and pass the event identifier
                    presentationMode.wrappedValue.dismiss()  // Dismiss the view
                }
                .disabled(assignmentTitle.isEmpty)
            }
            .navigationTitle("Add Assignment")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func deleteReminder(_ reminder: AppReminder) {
        reminders.removeAll { $0.id == reminder.id }
        print("Reminder Deleted: \(reminder.title)")
    }
}

// Define the `dateFormatter` used to format reminders
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
