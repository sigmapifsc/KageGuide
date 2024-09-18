//
//  ADHDCoachApp.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

import SwiftUI

@main
struct ADHDCoachApp: App {
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var viewModel = CoursesViewModel()
    @StateObject private var appSettings = AppSettings()  // Add AppSettings instance

    var body: some Scene {
        WindowGroup {
            ContentView()  // Changed from DashboardView to ContentView
                .environmentObject(calendarManager)
                .environmentObject(viewModel)
                .environmentObject(appSettings)  // Pass AppSettings to the environment
                .onAppear {
                    calendarManager.requestAccess { granted, error in
                        if granted {
                            print("Calendar and Reminders access granted.")
                        } else {
                            print("Access denied. Please enable Calendar and Reminders permissions in Settings.")
                        }
                    }
                }
        }
    }
}
