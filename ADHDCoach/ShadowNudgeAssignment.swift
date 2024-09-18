//
//  ShadowNudgeAssignment.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/14/24.
//

import Foundation

class ShadowNudgeAssignment {
    func activateNudge(for assignment: Assignment, daysLeft: Int, nudgeLevel: Float) {
        // Access strategySummary instead of summary
        let summary = assignment.strategySummary ?? "No strategy summary available."
        let prompt = "Your assignment is due in \(daysLeft) days. Here are the details: \(summary)."

        // Use ShadowNudgeManager to generate and schedule the nudge
        ShadowNudgeManager.shared.generateNudge(for: prompt) { nudgeText in
            ShadowNudgeManager.shared.scheduleNotification(
                title: "ShadowNudge for \(assignment.title)",
                body: nudgeText,
                timeInterval: TimeInterval(daysLeft * 86400),  // Days before due
                userInfo: ["assignmentId": assignment.id]
            )
        }
    }
}
