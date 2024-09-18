//
//  CrisisLogic.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/6/24.
//

import Foundation

class CrisisLogic {
    
    static func generateCrisisPlan(userInput: String, courses: [Course], appSettings: AppSettings, completion: @escaping (String) -> Void) {
        // Step 1: Collect assignments and sort them by due date
        let sortedAssignments = courses.flatMap { $0.assignments }
            .sorted { $0.dueDate < $1.dueDate }  // Sort assignments by due date

        // Step 2: Extract assignment details for the prompt
        let assignmentDetails = sortedAssignments.map { assignment in
            """
            Title: \(assignment.title)
            Due Date: \(formattedDate(assignment.dueDate))
            Details: \(assignment.details)
            """
        }.joined(separator: "\n\n")

        // Step 3: Extract syllabus summaries
        let syllabusDetails = courses.compactMap { $0.syllabusSummary ?? "No syllabus available" }
            .joined(separator: "\n\n")

        // Step 4: Select the appropriate prompt based on the learning style
        let prompt: String
        switch appSettings.learningStyle {
        case LearningStyle.adhd.rawValue:
            prompt = Prompts.crisisPlanPrompt(userInput: userInput, allAssignments: [assignmentDetails], allSyllabuses: [syllabusDetails])
        case LearningStyle.dyslexia.rawValue:
            prompt = Prompts.dyslexiaCrisisPlanPrompt(userInput: userInput, allAssignments: [assignmentDetails], allSyllabuses: [syllabusDetails])
        case LearningStyle.both.rawValue:
            prompt = Prompts.bothCrisisPlanPrompt(userInput: userInput, allAssignments: [assignmentDetails], allSyllabuses: [syllabusDetails])
        default:
            prompt = Prompts.noneCrisisPlanPrompt(userInput: userInput, allAssignments: [assignmentDetails], allSyllabuses: [syllabusDetails])
        }

        // Step 5: Call ChatGPT API with the generated prompt
        callChatGPTAPI(with: prompt) { response in
            completion(response)
        }
    }

    // Helper function to format date
    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Call ChatGPT API
    private static func callChatGPTAPI(with prompt: String, completion: @escaping (String) -> Void) {
        let apiKey = Constants.openApiKey
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a supportive assistant helping a student with their crisis plan."],
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion("Failed to get a response from ChatGPT: \(error.localizedDescription)")
                return
            }

            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = responseJSON["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let text = message["content"] as? String {
                    completion(text)
                } else {
                    completion("Failed to parse ChatGPT response.")
                }
            }
        }
        task.resume()
    }
}
