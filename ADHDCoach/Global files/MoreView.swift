//
//  MoreView.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/7/24.
//
//
//  MoreView.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/7/24.
//import SwiftUI
import SwiftUI

struct MoreView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showingPlansView = false  // Control showing the Plans view
    @State private var showingSettingsView = false  // Control showing the Settings view
    
    var body: some View {
        NavigationView {
            List {
                // Navigation link to the Plans View
                Button(action: {
                    showingPlansView = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Plans")
                    }
                }
                .sheet(isPresented: $showingPlansView) {
                    PlanView()  // Navigate to the PlanView
                        .environmentObject(appSettings)  // Pass AppSettings environment object
                }
                
                // Navigation link to Settings View
                Button(action: {
                    showingSettingsView = true
                }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
                .sheet(isPresented: $showingSettingsView) {
                    SettingsView()  // Assuming you have a SettingsView
                        .environmentObject(appSettings)  // Pass AppSettings environment object
                }
            }
            .navigationTitle("More")
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(AppSettings())  // Mock environment object for preview
            .environmentObject(CalendarManager())  // Mock calendar manager for preview
    }
}
