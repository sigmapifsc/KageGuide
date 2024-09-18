//
//  CourseArchiveView.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

import SwiftUI

struct CourseArchiveView: View {
    @Binding var archivedAssignments: [Assignment]
    var onUnarchive: (Assignment) -> Void

    var body: some View {
        List {
            ForEach(archivedAssignments) { assignment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(assignment.title)
                        Text("Due Date: \(assignment.dueDate, style: .date)")
                            .font(.caption)
                    }

                    Spacer()

                    Button(action: {
                        onUnarchive(assignment)
                    }) {
                        Image(systemName: "arrow.uturn.left.circle")
                            .foregroundColor(.green)
                    }
                    .padding(.trailing, 15)  // Add padding to separate icons

                    Button(action: {
                        deleteAssignment(assignment)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Archived Assignments")
    }

    private func deleteAssignment(_ assignment: Assignment) {
        archivedAssignments.removeAll { $0.id == assignment.id }
    }
}

import SwiftUI

struct CourseArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        let archivedAssignments = [
            Assignment(title: "Completed Assignment 1", dateAdded: Date(), dueDate: Date().addingTimeInterval(-86400), details: "Details of the completed assignment."),
            Assignment(title: "Completed Assignment 2", dateAdded: Date(), dueDate: Date().addingTimeInterval(-172800), details: "Details of another completed assignment.")
        ]

        return CourseArchiveView(archivedAssignments: .constant(archivedAssignments), onUnarchive: { _ in })
    }
}
