import SwiftUI

struct MasterSummaryView: View {
    var courses: [Course]
    @Binding var selectedTab: Int  // Binding for selectedTab to manage navigation

    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var appSettings: AppSettings
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingCrisisPlan = false  // State for showing Crisis Plan modal

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(courses) { course in
                        Section(header: Text(course.name)) {
                            ForEach(course.assignments) { assignment in
                                NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
                                    VStack(alignment: .leading) {
                                        Text(assignment.title)
                                            .font(.headline)
                                        Text("Due: \(assignment.dueDate, style: .date)(\(daysLeft(until: assignment.dueDate)))")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Master Summary")
                
                Spacer()  // To ensure the buttons don't overlap the content
                
                // Sync and Panic Buttons side by side at the bottom in a fixed position
                // Sync and Panic Buttons side by side at the bottom in a fixed position
                VStack {
                    Divider()  // Add a divider for separation
                    
                    HStack(spacing: 16) {  // Adjust the spacing between the buttons
                        // Master Sync Button
                        Button("Master Sync") {
                            performMasterSync()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)  // Keep height consistent with other buttons
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(appSettings.selectedCalendarName?.isEmpty ?? true)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Sync Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        // Panic Button
                        Button("Panic") {
                            showingCrisisPlan = true
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)  // Keep height consistent with other buttons
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .sheet(isPresented: $showingCrisisPlan) {
                            CrisisPlanView(appSettings: _appSettings, selectedTab: $selectedTab)
                        }
                    }
                    .padding(.horizontal)  // Add horizontal padding around the button group
                    .padding(.bottom, 20)  // Add bottom padding
                    .padding(.top, 16)  // Add top paddingto separate from the text
                }
            }
        }
    }

    // Function to sync all assignments to the selected calendar
    private func performMasterSync() {
        let calendarName = appSettings.selectedCalendarName ?? ""
        guard !calendarName.isEmpty else {
            alertMessage = "Please select a calendar in the settings to sync."
            showAlert = true
            return
        }

        for course in courses {
            for assignment in course.assignments {
                calendarManager.addOrUpdateEvent(
                    title: assignment.title,
                    dueDate: assignment.dueDate,
                    notes: assignment.details,
                    toCalendarWithName: calendarName,
                    eventIdentifier: assignment.eventIdentifier
                )
            }
        }

        alertMessage = "All assignments have been synced to \(calendarName)."
        showAlert = true
    }
}

struct MasterSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCourses = [
            Course(
                name: "Math",
                courseSchedule: [
                    ScheduleItem(day: "Monday", startTime: Date(), endTime: Date().addingTimeInterval(3600))
                ],
                courseColor: "blue",
                courseLocation: "Room 101",
                portalLink: URL(string: "https://example.com"),
                assignments: [
                    Assignment(title: "Homework 1", dateAdded: Date(), dueDate: Date().addingTimeInterval(86400), details: ""),
                    Assignment(title: "Homework 2", dateAdded: Date(), dueDate: Date().addingTimeInterval(172800), details: "")
                ]
            ),
            Course(
                name: "Science",
                courseSchedule: [
                    ScheduleItem(day: "Wednesday", startTime: Date(), endTime: Date().addingTimeInterval(3600))
                ],
                courseColor: "green",
                courseLocation: "Room 202",
                portalLink: URL(string: "https://example.com"),
                assignments: [
                    Assignment(title: "Lab Report", dateAdded: Date(), dueDate: Date().addingTimeInterval(432000), details: "")
                ]
            )
        ]

        MasterSummaryView(courses: sampleCourses, selectedTab: .constant(0))  // Bind selectedTab here
            .environmentObject(AppSettings())
            .environmentObject(CalendarManager())
    }
}
