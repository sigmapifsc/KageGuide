//
//  FeedbackPage.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/11/24.
//

import SwiftUI

struct FeedbackPage: View {
    @Binding var feedbackText: String  // Bind this to the parent view's state
    var onSubmit: () -> Void  // The action triggered when Submit is tapped
    
    // Access the presentationMode to go back after submission
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                TextField("What would you like to change in the strategy?", text: $feedbackText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Submit Feedback") {
                    print("Submit button tapped, feedback: \(feedbackText)")
                    onSubmit()  // Trigger the action when button is pressed
                    presentationMode.wrappedValue.dismiss()  // Dismiss the current view to go back
                }
                .padding()
                .background(Color.indigo)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Feedback")
        }
    }
}
