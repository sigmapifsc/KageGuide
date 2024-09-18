//
//  ShadowNudgeManager.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/14/24.
//

import Foundation
import UserNotifications

class ShadowNudgeManager {
    static let shared = ShadowNudgeManager()

    // Function to schedule notifications (used for assignments or crisis strategies)
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval, userInfo: [String: Any]?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let info = userInfo {
            content.userInfo = info
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    // Generate nudges based on GPT or static prompts
    func generateNudge(for prompt: String, completion: @escaping (String) -> Void) {
        // This is where you could integrate GPT to create intelligent nudge prompts.
        let generatedText = "Your assignment is due soon! Don't forget to start reading Chapter 1."
        completion(generatedText)
    }
}
