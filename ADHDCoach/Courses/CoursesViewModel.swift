//
//  CoursesViewModel.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/28/24.
//

import SwiftUI

class CoursesViewModel: ObservableObject {
    @Published var courses: [Course] {
        didSet {
            saveCourses()  // Automatically save courses whenever they change
        }
    }
    
    private let persistenceManager = PersistenceManager()
    
    init() {
        self.courses = persistenceManager.loadCourses()  // Load courses when the view model is initialized
    }
    
    func addCourse(
        name: String,
        courseSchedule: [ScheduleItem],  // Use the array of ScheduleItem
        color: String,
        courseLocation: String,
        portalLink: URL?
    ) {
        guard !name.isEmpty else { return }
        
        // Create a new Course with the correct structure
        let newCourse = Course(
            name: name,
            courseSchedule: courseSchedule,
            courseColor: color,
            courseLocation: courseLocation,
            portalLink: portalLink,
            assignments: []  // Initialize with an empty list of assignments
        )
        
        // Add the new course to the array
        courses.append(newCourse)
        
        // Save the updated course list
        saveCourses()
    }

    // Update the analysis results for a course
    func updateCourseAnalysis(course: Course, analysisResults: String) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index].analysisResults = analysisResults
            saveCourses()  // Save updated courses after modifying analysis results
        }
    }
    
    func saveCourses() {
        persistenceManager.saveCourses(courses)
    }
    
    func loadCourses() -> [Course] {
        return persistenceManager.loadCourses()
    }
}
