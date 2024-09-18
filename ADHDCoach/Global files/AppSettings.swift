//
//  AppSettings.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/30/24.
//

import SwiftUI
import UserNotifications

class AppSettings: ObservableObject {
    @Published var schoolName: String {
        didSet {
            UserDefaults.standard.set(schoolName, forKey: "schoolName")
        }
    }

    @Published var selectedCalendarName: String? {
        didSet {
            UserDefaults.standard.set(selectedCalendarName, forKey: "selectedCalendarName")
        }
    }

    @Published var chatGPTTone: String {
        didSet {
            UserDefaults.standard.set(chatGPTTone, forKey: "chatGPTTone")
        }
    }

    @Published var learningStyle: String {
        didSet {
            UserDefaults.standard.set(learningStyle, forKey: "learningStyle")
        }
    }

    @Published var activePlan: Plan? {
        didSet {
            if let activePlan = activePlan {
                let planData = try? JSONEncoder().encode(activePlan)
                UserDefaults.standard.set(planData, forKey: "activePlan")
            } else {
                UserDefaults.standard.removeObject(forKey: "activePlan")
            }
        }
    }

    @Published var activePlanSteps: [String]? {
        didSet {
            UserDefaults.standard.set(activePlanSteps, forKey: "activePlanSteps")
        }
    }

    @Published var isPlanActive: Bool {
        didSet {
            UserDefaults.standard.set(isPlanActive, forKey: "isPlanActive")
        }
    }

    @Published var savedPlans: [Plan] {
        didSet {
            if let encoded = try? JSONEncoder().encode(savedPlans) {
                UserDefaults.standard.set(encoded, forKey: "savedPlans")
            }
        }
    }

    @Published var courses: [Course] = []  // Add courses to AppSettings
    @Published var syllabuses: [URL] = []  // Store syllabus URLs (for PDFs)

    // Initialization from UserDefaults
    init() {
        self.schoolName = UserDefaults.standard.string(forKey: "schoolName") ?? ""
        self.selectedCalendarName = UserDefaults.standard.string(forKey: "selectedCalendarName")
        self.chatGPTTone = UserDefaults.standard.string(forKey: "chatGPTTone") ?? "Warm and Supportive"
        self.learningStyle = UserDefaults.standard.string(forKey: "learningStyle") ?? LearningStyle.none.rawValue

        if let activePlanData = UserDefaults.standard.data(forKey: "activePlan"),
           let activePlan = try? JSONDecoder().decode(Plan.self, from: activePlanData) {
            self.activePlan = activePlan
        } else {
            self.activePlan = nil
        }

        self.activePlanSteps = UserDefaults.standard.stringArray(forKey: "activePlanSteps")
        self.isPlanActive = UserDefaults.standard.bool(forKey: "isPlanActive")

        if let savedPlansData = UserDefaults.standard.data(forKey: "savedPlans"),
           let decodedPlans = try? JSONDecoder().decode([Plan].self, from: savedPlansData) {
            self.savedPlans = decodedPlans
        } else {
            self.savedPlans = []
        }

        // Initialize courses from UserDefaults if needed
        if let coursesData = UserDefaults.standard.data(forKey: "courses"),
           let decodedCourses = try? JSONDecoder().decode([Course].self, from: coursesData) {
            self.courses = decodedCourses
        }

        // Initialize syllabus URLs
        if let syllabusURLs = UserDefaults.standard.array(forKey: "syllabuses") as? [String] {
            self.syllabuses = syllabusURLs.compactMap { URL(string: $0) }
        }
        
        requestNotificationPermissions()  // Request permission when app is initialized
    }

    // Request Notification Permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }

    // Schedule ShadowNudge Notifications
    func scheduleShadowNudgeNotification(for assignment: Assignment, nudgeLevel: Float) {
        let content = UNMutableNotificationContent()
        content.title = "ShadowNudge: \(assignment.title)"
        content.body = "Your assignment is due in \(daysLeft(until: assignment.dueDate)) days."
        content.sound = UNNotificationSound.default

        // Calculate when to trigger the notification based on nudge level
        let daysBefore = calculateDaysBeforeNudge(nudgeLevel: nudgeLevel)
        var triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: assignment.dueDate) ?? Date()

        // Ensure the notification does not trigger between 9 PM and 6 AM
        let hourComponent = Calendar.current.component(.hour, from: triggerDate)
        
        if hourComponent >= 21 {  // If it's 9 PM or later
            // Move the trigger time to 6 AM the next day
            triggerDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: triggerDate.addingTimeInterval(86400)) ?? triggerDate
            print("Nudge time adjusted to next day at 6 AM")
        } else if hourComponent < 6 {  // If it's before 6 AM
            // Move the trigger time to 6 AM the same day
            triggerDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: triggerDate) ?? triggerDate
            print("Nudge time adjusted to 6 AM")
        }

        // Calculate time interval from now
        let timeInterval = triggerDate.timeIntervalSinceNow
        print("Scheduling ShadowNudge notification for \(assignment.title) at \(triggerDate) (in \(timeInterval) seconds).")

        if timeInterval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling ShadowNudge notification: \(error.localizedDescription)")
                } else {
                    print("ShadowNudge notification scheduled for \(assignment.title) at \(triggerDate).")
                }
            }
        } else {
            print("Error: Notification trigger time interval is invalid. No notification scheduled.")
        }
    }

    // Cancel ShadowNudge Notifications
    func cancelShadowNudgeNotifications(for assignment: Assignment) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All ShadowNudge notifications canceled for assignment \(assignment.title)")
    }

    // Calculate days before due date to nudge
    private func calculateDaysBeforeNudge(nudgeLevel: Float) -> Int {
        let maxDaysBeforeDueDate = 7  // Start nudging a week before the due date
        return Int(nudgeLevel * Float(maxDaysBeforeDueDate))  // Adjust days based on nudge level
    }

    // Helper function to calculate days left until the due date
    func daysLeft(until dueDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
        return components.day ?? 0
    }

    // Reset settings to default
    func resetSettings() {
        UserDefaults.standard.removeObject(forKey: "schoolName")
        UserDefaults.standard.removeObject(forKey: "selectedCalendarName")
        UserDefaults.standard.removeObject(forKey: "chatGPTTone")
        UserDefaults.standard.removeObject(forKey: "learningStyle")
        UserDefaults.standard.removeObject(forKey: "activePlan")
        UserDefaults.standard.removeObject(forKey: "activePlanSteps")
        UserDefaults.standard.removeObject(forKey: "isPlanActive")
        UserDefaults.standard.removeObject(forKey: "savedPlans")
        UserDefaults.standard.removeObject(forKey: "courses")
        UserDefaults.standard.removeObject(forKey: "syllabuses")

        self.schoolName = ""
        self.selectedCalendarName = nil
        self.chatGPTTone = "Warm and Supportive"
        self.learningStyle = LearningStyle.none.rawValue
        self.activePlan = nil
        self.activePlanSteps = nil
        self.isPlanActive = false
        self.savedPlans = []
        self.courses = []
        self.syllabuses = []
    }

    // Method to export data for backup
    func exportData() -> Data? {
        let backupData = BackupData(
            schoolName: schoolName,
            selectedCalendarName: selectedCalendarName,
            chatGPTTone: chatGPTTone,
            learningStyle: learningStyle,
            activePlan: activePlan,
            activePlanSteps: activePlanSteps,
            savedPlans: savedPlans,
            courses: courses,
            syllabuses: syllabuses.map { $0.absoluteString }  // Convert syllabus URLs to strings
        )
        return try? JSONEncoder().encode(backupData)
    }

    // Method to import data from backup
    func importData(from data: Data) {
        if let backupData = try? JSONDecoder().decode(BackupData.self, from: data) {
            self.schoolName = backupData.schoolName
            self.selectedCalendarName = backupData.selectedCalendarName
            self.chatGPTTone = backupData.chatGPTTone
            self.learningStyle = backupData.learningStyle
            self.activePlan = backupData.activePlan
            self.activePlanSteps = backupData.activePlanSteps
            self.savedPlans = backupData.savedPlans
            self.courses = backupData.courses
            self.syllabuses = backupData.syllabuses.compactMap { URL(string: $0) }  // Convert strings back to URLs
            self.isPlanActive = backupData.activePlan != nil
        }
    }
}

// Data model for backup
struct BackupData: Codable {
    let schoolName: String
    let selectedCalendarName: String?
    let chatGPTTone: String
    let learningStyle: String
    let activePlan: Plan?
    let activePlanSteps: [String]?
    let savedPlans: [Plan]
    let courses: [Course]
    let syllabuses: [String]
}
