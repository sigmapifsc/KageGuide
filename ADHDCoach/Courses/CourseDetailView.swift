import SwiftUI
import AudioToolbox
import PDFKit

struct CourseDetailView: View {
    @Binding var course: Course
    @Binding var selectedTab: Int  // Added selectedTab as a Binding
    
    @State private var archivedAssignments: [Assignment] = []
    @State private var showingAddAssignmentSheet = false
    @State private var showingEditAssignmentSheet = false
    @State private var showingAssignmentDetailView = false
    @State private var newAssignmentTitle = ""
    @State private var newAssignmentDescription = ""
    @State private var newDueDate = Date()
    @State private var reminders: [AppReminder] = []
    @State private var editingAssignment: Assignment?
    @State private var selectedAssignment: Assignment?
    @State private var isContactViewPresented = false
    @State private var syllabusURL: URL?
    @State private var showingEditCourseSheet = false
    @State private var selectedColor: Color = .blue
    @State private var showDocumentPicker = false
    @State private var pdfText: String = ""
    
    private let openAIService = OpenAIService()  // Add OpenAI service instance
    
    var onSave: () -> Void
    var calendarManager: CalendarManager
    var viewModel: CoursesViewModel
    var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            // Display course location and schedule
            Text(course.courseLocation)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 2)
            
            ForEach(course.courseSchedule, id: \.id) { item in
                Text("\(item.day): \(formatTime(item.startTime)) - \(formatTime(item.endTime))")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 1)
            }
            
            Spacer()

            HStack {
                // Add Assignment Button
                Button(action: {
                    showingAddAssignmentSheet = true
                }) {
                    Image(systemName: "plus")
                    Text("Add Assignment")
                }
                .sheet(isPresented: $showingAddAssignmentSheet) {
                    AddAssignmentView(
                        assignmentTitle: $newAssignmentTitle,
                        assignmentDescription: $newAssignmentDescription,
                        dueDate: $newDueDate,
                        reminders: $reminders,
                        onSave: { eventIdentifier in
                            addAssignment(
                                title: newAssignmentTitle,
                                description: newAssignmentDescription,
                                dueDate: newDueDate,
                                reminders: reminders,
                                eventIdentifier: eventIdentifier
                            )
                        },
                        calendarManager: calendarManager,
                        schoolCalendarName: appSettings.selectedCalendarName ?? ""
                    )
                }

                Spacer()

                // View or Add Syllabus
                if let syllabusURL = syllabusURL {
                    NavigationLink(destination: PDFViewer(
                        url: syllabusURL,
                        analysisResult: Binding(
                            get: { course.analysisResults ?? "" },
                            set: { course.analysisResults = $0 }
                        ),
                        onAnalyze: course.analysisResults == nil ? analyzeSyllabus : nil
                    )) {
                        Image(systemName: "doc.text")
                        Text("View Syllabus")
                    }
                } else {
                    Button(action: {
                        print("Add Syllabus button tapped")
                        selectedTab = 3  // Switch to Import Tab
                    }) {
                        Image(systemName: "doc.text")
                        Text("Add Syllabus")
                    }
                }

                Spacer()

                // Contact Button
                Button(action: {
                    isContactViewPresented = true
                }) {
                    Image(systemName: "phone")
                    Text("Contact")
                }
                .sheet(isPresented: $isContactViewPresented) {
                    ContactView()
                }
            }
            .padding()

            // Assignments List
            List {
                ForEach(course.assignments.indices, id: \.self) { index in
                    NavigationLink(destination: AssignmentDetailView(assignment: course.assignments[index])) {
                        HStack {  // Create a horizontal layout
                            VStack(alignment: .leading) {  // Title and due date stay on the left
                                // Show the assignment title with the days left next to it
                                Text("\(course.assignments[index].title) (\(daysLeft(until: course.assignments[index].dueDate)))")
                                
                                // Keep the due date as before
                                Text("Due Date: \(course.assignments[index].dueDate, style: .date)")
                                    .font(.caption)
                            }
                            
                            Spacer()  // Add a spacer to push buttons to the right
                            
                            HStack {  // Buttons will be aligned to the right
                                // Archive Button
                                Button(action: {
                                    archiveAssignment(course.assignments[index])
                                }) {
                                    Image(systemName: "tray.and.arrow.down.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())

                                // Delete Button
                                Button(action: {
                                    deleteAssignment(at: IndexSet(integer: index))
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
                .onDelete(perform: deleteAssignment)
            }
        }
        .navigationTitle(course.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditCourseSheet = true
                }) {
                    Image(systemName: "pencil")
                }
                .sheet(isPresented: $showingEditCourseSheet) {
                    AddCourseView(
                        courseName: $course.name,
                        selectedColor: $selectedColor,
                        courseLocation: $course.courseLocation,
                        courseSchedule: $course.courseSchedule,
                        portalLink: .constant(course.portalLink?.absoluteString ?? ""),
                        onSave: onSave
                    )
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Archive", destination: CourseArchiveView(archivedAssignments: $archivedAssignments, onUnarchive: { unarchiveAssignment in
                    unarchive(unarchiveAssignment)
                }))
            }
        }
        .sheet(isPresented: $showingEditAssignmentSheet) {
            if let assignment = editingAssignment {
                EditAssignmentView(assignment: $editingAssignment, onSave: {
                    saveAssignment(assignment)
                })
            }
        }
        .sheet(isPresented: $showingAssignmentDetailView) {
            if let assignment = selectedAssignment {
                AssignmentDetailView(assignment: assignment)
            }
        }
        .onAppear {
            syllabusURL = FileManagerHelper.shared.listPDFFiles().first(where: { $0.lastPathComponent.contains(course.name) })
        }
    }
    
    // Helper Methods
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func addAssignment(title: String, description: String, dueDate: Date, reminders: [AppReminder], eventIdentifier: String?) {
        guard !title.isEmpty else { return }
        
        var newAssignment = Assignment(
            title: title,
            dateAdded: Date(),
            dueDate: dueDate,
            details: description,
            reminders: reminders
        )
        
        newAssignment.eventIdentifier = eventIdentifier
        course.assignments.append(newAssignment)
        
        newAssignmentTitle = ""
        newAssignmentDescription = ""
        newDueDate = Date()
        self.reminders = []
        
        onSave()
    }
    
    private func saveAssignment(_ assignment: Assignment?) {
        guard let assignment = assignment else { return }
        if let index = course.assignments.firstIndex(where: { $0.id == assignment.id }) {
            var updatedAssignment = assignment
            updatedAssignment.eventIdentifier = calendarManager.addOrUpdateEvent(
                title: assignment.title,
                dueDate: assignment.dueDate,
                notes: assignment.details,
                toCalendarWithName: appSettings.selectedCalendarName ?? "",
                eventIdentifier: assignment.eventIdentifier
            )
            course.assignments[index] = updatedAssignment
            onSave()
        }
    }

    private func deleteAssignment(at offsets: IndexSet) {
        for index in offsets {
            if let eventIdentifier = course.assignments[index].eventIdentifier {
                calendarManager.deleteEvent(withIdentifier: eventIdentifier)
            }
        }
        course.assignments.remove(atOffsets: offsets)
        onSave()
    }
    
    private func archiveAssignment(_ assignment: Assignment) {
        if let index = course.assignments.firstIndex(where: { $0.id == assignment.id }) {
            if let eventIdentifier = course.assignments[index].eventIdentifier {
                calendarManager.deleteEvent(withIdentifier: eventIdentifier)
            }
            archivedAssignments.append(course.assignments.remove(at: index))
            onSave()
        }
    }

    private func unarchive(_ assignment: Assignment) {
        if let index = archivedAssignments.firstIndex(where: { $0.id == assignment.id }) {
            let unarchivedAssignment = archivedAssignments.remove(at: index)
            course.assignments.append(unarchivedAssignment)
            onSave()
        }
    }

    private func analyzeSyllabus() {
        guard !pdfText.isEmpty else { return }

        let prompt = """
        Please summarize the following syllabus in an outline format with bullet points.
        Focus on the number of textbooks required, the number of units, assignments, and any key objectives or important information.
        Here is the syllabus: \(pdfText)
        """

        openAIService.generateStrategyAndMotivation(prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Syllabus Analysis: \(response.strategy)")
                    if let syllabusURL = syllabusURL {
                        // Save the syllabus analysis to the course
                        course.analysisResults = response.strategy
                        onSave()
                    }
                case .failure(let error):
                    print("Failed to generate summary: \(error.localizedDescription)")
                }
            }
        }
    }

    private func playCompletionSound() {
        if let soundURL = Bundle.main.url(forResource: "complete", withExtension: "wav") {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
