//
//  SyllabusSummaryView.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/27/24.
//

import SwiftUI

struct SyllabusSummaryView: View {
    var courseTitle: String
    var summary: String
    var onSave: () -> Void
    var onClose: () -> Void
    
    @State private var showSyllabusShareSheet = false  // State to handle sharing
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(courseTitle)
                        .font(.largeTitle)
                        .bold()

                    Text("Course Summary")
                        .font(.title2)
                        .padding(.top)

                    // Display summary as bullet points
                    ForEach(summary.split(separator: "\n"), id: \.self) { line in
                        if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("• \(line)")
                                .font(.body)
                                .padding(.bottom, 5)
                        }
                    }

                    Text("You can do this! Stay on track and reach out if you need help. You've got this!")
                        .font(.body)
                        .italic()
                        .padding(.top)
                }
                .padding()
            }

            // Buttons for "Send" and "Save & Close"
            HStack {
                // Send button with icon
                Button(action: shareSummary) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")  // Icon for sending
                        Text("Send")
                    }
                    .padding()
                    .frame(height: 30)

                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                // Save & Close button with icon
                Button(action: {
                    onSave()
                    onClose()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")  // Icon for saving
                        Text("Save & Close")
                    }
                    .padding()
                    .frame(height: 30)

                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .sheet(isPresented: $showSyllabusShareSheet) {
                SyllabusShareSheet(items: [summary])  // Share only the summary
            }
        }
        .navigationTitle("Syllabus Summary")
        .onAppear(perform: onSave)  // Auto-save on appear
    }
    
    private func shareSummary() {
        print("Sharing summary text.")
        showSyllabusShareSheet = true
    }
}

// Preview for testing UI
struct SyllabusSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SyllabusSummaryView(
            courseTitle: "Sample Course",
            summary: """
            - Textbooks: 3 required
            - Units: 6
            - Assignments: 4 major assignments
            - Important Information: Stay on track with weekly readings and participate in discussions.
            """,
            onSave: {},
            onClose: {}
        )
    }
}
