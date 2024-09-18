import SwiftUI

struct CoursesView: View {
    @Binding var courses: [Course]
    
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var appSettings: AppSettings
    var viewModel: CoursesViewModel

    @State private var showingAddCourseSheet = false
    @State private var newCourseName = ""
    @State private var newCourseColor = Color.blue  // Default color
    @State private var newCourseLocation = ""
    @State private var newCourseSchedule: [ScheduleItem] = []  // Use an array of ScheduleItem
    @State private var newCoursePortalLink: String = ""  // Updated to String to match the AddCourseView

    @State private var showingDeleteConfirmation = false
    @State private var courseToDelete: Course?

    @Binding var selectedTab: Int  // This line binds to selectedTab for tab navigation

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showingAddCourseSheet = true
                }) {
                    Text("Add Course")
                        .padding()
                        .frame(height: 30)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingAddCourseSheet) {
                    AddCourseView(
                        courseName: $newCourseName,
                        selectedColor: $newCourseColor,
                        courseLocation: $newCourseLocation,
                        courseSchedule: $newCourseSchedule,
                        portalLink: $newCoursePortalLink,
                        onSave: {
                            let newCourse = Course(
                                name: newCourseName,
                                courseSchedule: newCourseSchedule,
                                courseColor: newCourseColor.description,  // Convert color to a string
                                courseLocation: newCourseLocation,
                                portalLink: URL(string: newCoursePortalLink),  // Convert string to URL
                                assignments: []  // Start with an empty list of assignments
                            )
                            courses.append(newCourse)
                            saveCourses()  // Save courses after adding the new one

                            // Clear the fields after saving
                            newCourseName = ""
                            newCourseColor = Color.blue
                            newCourseLocation = ""
                            newCourseSchedule = []
                            newCoursePortalLink = ""
                        }
                    )
                }

                NavigationLink(destination: MasterSummaryView(courses: courses, selectedTab: $selectedTab)) {
                    Text("Master Summary")
                        .padding()
                        .frame(height: 30)
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                List {
                    ForEach(courses) { course in
                        NavigationLink(destination: CourseDetailView(
                            course: $courses[courses.firstIndex(where: { $0.id == course.id })!],
                            selectedTab: $selectedTab,  // Bind the selectedTab to this view
                            onSave: saveCourses,
                            calendarManager: calendarManager,
                            viewModel: viewModel,
                            appSettings: appSettings  // Pass the AppSettings object
                        )) {
                            Text(course.name)
                        }
                    }
                    .onDelete(perform: confirmDelete)  // Handle delete action
                }
            }
            .navigationTitle("Courses")
            .onAppear {
                loadCourses()
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete Course"),
                    message: Text("Are you sure you want to delete this course? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteCourse()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            courseToDelete = courses[index]
            showingDeleteConfirmation = true
        }
    }

    private func deleteCourse() {
        if let course = courseToDelete, let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses.remove(at: index)
            saveCourses()  // Save the updated courses array
        }
        courseToDelete = nil  // Reset the courseToDelete after deletion
    }

    private func saveCourses() {
        viewModel.saveCourses()  // Ensure the saveCourses method accepts a [Course] parameter
    }

    private func loadCourses() {
        courses = viewModel.loadCourses()  // Ensure `loadCourses()` returns `[Course]`
    }
}

struct CoursesView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview without the `@Binding` variable issue, use a constant state here
        CoursesView(courses: .constant([]), viewModel: CoursesViewModel(), selectedTab: .constant(0))
            .environmentObject(AppSettings())  // Add the AppSettings environment object
            .environmentObject(CalendarManager())  // Use environment object for CalendarManager
    }
}
