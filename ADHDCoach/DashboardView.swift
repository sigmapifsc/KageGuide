import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var viewModel: CoursesViewModel
    @EnvironmentObject var appSettings: AppSettings  // To access active plan settings

    @State private var newCourseColor: Color = .blue  // Default color for a new course
    @State private var newCourseLocation: String = ""  // Default location
    @State private var newCourseSchedule: [ScheduleItem] = []  // Default schedule
    @State private var newCoursePortalLink: String = ""  // Default portal link
    @Binding var selectedTab: Int  // Use a binding for the selected tab
    @State private var isFlashing = false  // State to handle button flashing

    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: UIImage(named: "KageShadow")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.3)

                VStack(spacing: 20) {
                    Spacer()

                    // Display number of courses and total assignments
                    Text("Number of Courses: \(viewModel.courses.count)")
                    Text("Total Number of Assignments: \(totalAssignments())")

                    // Flashing button if a plan is active
                    if appSettings.isPlanActive, let activePlan = appSettings.activePlan {
                        Button(action: {
                            // Navigate to the active plan's detail view using NavigationLink
                            selectedTab = 4  // Assuming Plans tab is index 4
                        }) {
                            NavigationLink(destination: PlanDetailView(plan: activePlan)) {
                                Text("Plan in Action")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(isFlashing ? Color.red : Color.indigo)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .onAppear {
                                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                            isFlashing.toggle()
                                        }
                                    }
                            }
                        }
                    }

                    // Welcome message and add course button
                    if viewModel.courses.isEmpty || allAssignmentsAreEmpty() {
                        Text("Welcome to KageGuide")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                            .padding(.bottom, 10)

                        Text("""
                        To power up KageGuide, your first task is to add your courses, the course syllabus, and any assignments.
                        From there, your KageGuide will be empowered to assist you.
                        """)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.indigo.opacity(0.8))
                            .cornerRadius(15)
                            .padding(.horizontal)

                        // Add Courses Button
                        Button(action: {
                            selectedTab = 1  // Change to the "Courses" tab
                        }) {
                            Text("Add Courses")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mint)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    } else {
                        // Next Class Section (Tappable with NavigationLink)
                        VStack {
                            Text("Your Next Class:")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            if let nextClass = getNextClass() {
                                NavigationLink(
                                    destination: CourseDetailView(
                                        course: Binding(
                                            get: { nextClass },
                                            set: { _ in }
                                        ),
                                        selectedTab: $selectedTab,  // Pass the selectedTab
                                        onSave: { viewModel.saveCourses() },
                                        calendarManager: calendarManager,
                                        viewModel: viewModel,
                                        appSettings: appSettings
                                    )
                                ) {
                                    VStack(alignment: .leading) {
                                        Text(nextClass.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Next class: \(nextClass.scheduleDescription())")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.bottom, 10)
                                }
                            } else {
                                Text("No upcoming classes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.horizontal)

                        // Next Assignment Section (Tappable with NavigationLink)
                        VStack {
                            Text("Your Next Assignment:")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            if let nextAssignment = getNextAssignment() {
                                NavigationLink(
                                    destination: AssignmentDetailView(assignment: nextAssignment)
                                ) {
                                    VStack(alignment: .leading) {
                                        Text("\(nextAssignment.title) (\(daysLeft(until: nextAssignment.dueDate)))")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Due: \(formattedDate(nextAssignment.dueDate))")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.bottom, 10)
                                }
                            } else {
                                Text("No upcoming assignments")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
            .navigationBarTitle("Dashboard", displayMode: .inline)  // Add navigation title
        }
    }

    // Method to calculate total number of assignments across all courses
    private func totalAssignments() -> Int {
        return viewModel.courses.reduce(0) { $0 + $1.assignments.count }
    }

    private func getNextClass() -> Course? {
        let currentDate = Date()
        let calendar = Calendar.current
        return viewModel.courses.first  // Simplified logic for example
    }

    private func getNextAssignment() -> Assignment? {
        let currentDate = Date()
        return viewModel.courses.flatMap { $0.assignments }
            .filter { $0.dueDate > currentDate }
            .sorted { $0.dueDate < $1.dueDate }
            .first
    }

    // Helper method to check if all courses have no assignments
    private func allAssignmentsAreEmpty() -> Bool {
        return viewModel.courses.allSatisfy { $0.assignments.isEmpty }
    }

    // Helper method to format assignment due dates
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(selectedTab: .constant(0))  // Bind the selectedTab here
            .environmentObject(CalendarManager())
            .environmentObject(CoursesViewModel())
            .environmentObject(AppSettings())
    }
}
