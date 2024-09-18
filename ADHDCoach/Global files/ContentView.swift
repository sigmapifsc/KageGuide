import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CoursesViewModel()
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var appSettings = AppSettings()

    @State private var selectedTab = 0  // State variable for the currently selected tab

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard/Home Tab
            DashboardView(selectedTab: $selectedTab)
                .environmentObject(appSettings)
                .environmentObject(calendarManager)
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            // Courses Tab
            CoursesView(courses: $viewModel.courses, viewModel: viewModel, selectedTab: $selectedTab)
                .environmentObject(appSettings)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "book")
                    Text("Courses")
                }
                .tag(1)

            // Summary Tab
            MasterSummaryView(courses: viewModel.courses, selectedTab: $selectedTab)
                .environmentObject(appSettings)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Summary")
                }
                .tag(2)

            // Import Tab
            ImportView(courses: $viewModel.courses, viewModel: viewModel)
                .environmentObject(appSettings)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "tray.and.arrow.down")
                    Text("Syllabus")
                }
                .tag(3)

            // More Tab (Remove selectedTab here)
            MoreView()  // No need to pass selectedTab here
                .environmentObject(appSettings)
                .environmentObject(calendarManager)
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .tag(4)
        }
        .onAppear {
            calendarManager.requestAccess { calendarGranted, reminderGranted in
                if !calendarGranted || !reminderGranted {
                    print("Access denied. Please enable Calendar and Reminders permissions in Settings.")
                }
            }
        }
    }
}
