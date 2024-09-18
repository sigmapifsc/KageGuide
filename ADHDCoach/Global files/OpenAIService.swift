//
//  OpenAIService.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/26/24.
//

import Foundation

class OpenAIService {
    private let apiKey = Constants.openApiKey
    
    // Function to generate both strategy and motivational message
    func generateStrategyAndMotivation(prompt: String, completion: @escaping (Result<StrategyResponse, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        var request = URLRequest(url: url, timeoutInterval: 30)  // Increased timeout to 30 seconds
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Modify the prompt to include prioritization and comforting tone
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a supportive assistant helping a student with ADHD. Your task is to provide a prioritized step-by-step plan for their assignments, considering due dates. Include motivational and comforting language throughout."],
                ["role": "user", "content": prompt]
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        print("Sending request to OpenAI API with prompt: \(prompt)")  // Log request prompt
        
        sendRequestWithRetry(request, completion: completion)
    }
    
    // Request function with retry logic for resilience in case of network issues
    private func sendRequestWithRetry(_ request: URLRequest, retryCount: Int = 3, completion: @escaping (Result<StrategyResponse, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as NSError?, error.code == NSURLErrorTimedOut, retryCount > 0 {
                print("Request timed out, retrying... (\(retryCount) retries left)")
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    self.sendRequestWithRetry(request, retryCount: retryCount - 1, completion: completion)
                }
                return
            } else if let error = error {
                print("Request failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(.failure(NSError(domain: "com.openai.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("Response: \(content)")
                    // Parse both strategy and motivation from the response
                    completion(.success(StrategyResponse(strategy: content, motivation: self.extractMotivation(from: content))))
                } else {
                    completion(.failure(NSError(domain: "com.openai.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Function to extract motivational content from the response
    private func extractMotivation(from content: String) -> String {
        // Identify motivation and encouragement based on keywords in the response
        if let motivationStart = content.range(of: "Motivation:") {
            let motivation = content[motivationStart.upperBound...]
            return motivation.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let comfortStart = content.range(of: "Encouragement:") {
            let comfort = content[comfortStart.upperBound...]
            return comfort.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Keep going! You're doing great!"
    }
}

struct StrategyResponse {
    let strategy: String
    let motivation: String
}
