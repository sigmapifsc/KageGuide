//
//  Models.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

//
//  Models.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

import Foundation
import SwiftUI

struct AppReminder: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var dueDate: Date
    var notes: String?
}

struct Assignment: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var dateAdded: Date
    var dueDate: Date
    var details: String
    var reminders: [AppReminder] = []
    var eventIdentifier: String?  // Calendar event identifier
    var strategySummary: String?  // Property for storing strategy summary
}

struct ScheduleItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var day: String  // e.g., "Monday", "Tuesday"
    var startTime: Date
    var endTime: Date
}

struct Course: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var courseSchedule: [ScheduleItem] = []  // Renamed from `schedule`
    var courseColor: String  // Renamed from `color`
    var courseLocation: String  // Renamed from `location`
    var portalLink: URL?
    var assignments: [Assignment] = []
    var analysisResults: String?  // Property to store analysis summary
    var syllabusSummary: String?  // Property for storing syllabus summary

    // Computed property to convert the color string to a Color object
    var uiColor: Color {
        switch courseColor.lowercased() {
        case "blue":
            return .blue
        case "red":
            return .red
        case "green":
            return .green
        default:
            return .black  // Fallback color
        }
    }

    // Conformance to Equatable
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.courseSchedule == rhs.courseSchedule &&
               lhs.courseColor == rhs.courseColor &&
               lhs.courseLocation == rhs.courseLocation &&
               lhs.portalLink == rhs.portalLink &&
               lhs.assignments == rhs.assignments &&
               lhs.analysisResults == rhs.analysisResults &&
               lhs.syllabusSummary == rhs.syllabusSummary
    }

    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(courseSchedule)
        hasher.combine(courseColor)
        hasher.combine(courseLocation)
        hasher.combine(portalLink)
        hasher.combine(assignments)
        hasher.combine(analysisResults)
        hasher.combine(syllabusSummary)
    }
}

extension Course {
    func scheduleDescription() -> String {
        guard let nextSchedule = courseSchedule.first else { return "No schedule available" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, h:mm a"  // EEEE is the full day of the week, h:mm a is time (12-hour format)
        return "\(nextSchedule.day), \(formatter.string(from: nextSchedule.startTime))"
    }
}

// New Plan model
struct Plan: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String  // The name of the plan
    var steps: [String]  // List of steps in the plan
    var isActive: Bool = false  // Whether the plan is active

    // Explicit conformance to Equatable
    static func == (lhs: Plan, rhs: Plan) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.steps == rhs.steps &&
               lhs.isActive == rhs.isActive
    }

    // Explicit conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(steps)
        hasher.combine(isActive)
    }
}
