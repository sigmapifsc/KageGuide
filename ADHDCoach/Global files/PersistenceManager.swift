//
//  PersistenceManager.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

import Foundation

class PersistenceManager {
    private let coursesKey = "coursesKey"
    private let syllabusesDirectoryName = "Syllabuses"

    // Save courses to UserDefaults
    func saveCourses(_ courses: [Course]) {
        do {
            let data = try JSONEncoder().encode(courses)
            UserDefaults.standard.set(data, forKey: coursesKey)
            print("Saving Courses:")
            for course in courses {
                print("Course Name: \(course.name)")
                print("Course Location: \(course.courseLocation)")
                print("Course Schedule: \(course.courseSchedule)")
                print("Assignments: \(course.assignments.count) assignments")
                if let analysis = course.analysisResults {
                    print("Analysis: \(analysis)")
                }
            }
        } catch {
            print("Failed to save courses: \(error.localizedDescription)")
        }
    }

    func loadCourses() -> [Course] {
        guard let data = UserDefaults.standard.data(forKey: coursesKey) else {
            print("No courses found in UserDefaults.")
            return []
        }

        do {
            let courses = try JSONDecoder().decode([Course].self, from: data)
            print("Courses loaded successfully:")
            for course in courses {
                print("Course Name: \(course.name)")
                if let analysis = course.analysisResults {
                    print("Analysis: \(analysis)")
                }
            }
            return courses
        } catch {
            print("Failed to load courses: \(error.localizedDescription)")
            return []
        }
    }

    // List syllabuses (PDF URLs)
    func listSyllabuses() -> [URL] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let syllabusesDirectory = documentsDirectory.appendingPathComponent(syllabusesDirectoryName)

        do {
            let urls = try FileManager.default.contentsOfDirectory(at: syllabusesDirectory, includingPropertiesForKeys: nil)
            return urls.filter { $0.pathExtension == "pdf" }
        } catch {
            print("Error listing syllabuses: \(error.localizedDescription)")
            return []
        }
    }

    // Restore syllabuses (PDF URLs)
    func restoreSyllabuses(_ syllabusURLs: [URL]) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let syllabusesDirectory = documentsDirectory.appendingPathComponent(syllabusesDirectoryName)

        // Create Syllabuses directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: syllabusesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: syllabusesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create syllabuses directory: \(error.localizedDescription)")
            }
        }

        // Copy the provided syllabus files to the app's Syllabuses directory
        for syllabusURL in syllabusURLs {
            let destinationURL = syllabusesDirectory.appendingPathComponent(syllabusURL.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: syllabusURL, to: destinationURL)
            } catch {
                print("Failed to restore syllabus file: \(error.localizedDescription)")
            }
        }
    }

    // Clear all saved courses (optional)
    func clearCourses() {
        UserDefaults.standard.removeObject(forKey: coursesKey)
        print("All courses cleared from UserDefaults.")
    }
    
    // Clear all data from UserDefaults
    func clearAllUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            print("All data cleared from UserDefaults.")
        }
    }
}
