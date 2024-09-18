// BackupManager.swift
// KageGuide

import Foundation
import ZIPFoundation

struct UnifiedBackupData: Codable {
    let schoolName: String
    let selectedCalendarName: String?
    let chatGPTTone: String
    let activePlan: Plan?
    let activePlanSteps: [String]?
    let savedPlans: [Plan]
    let courses: [Course]
    let syllabuses: [String]  // URLs of syllabus PDFs
}

class BackupManager {
    let appSettings: AppSettings
    let persistenceManager: PersistenceManager
    private let fileManager = FileManager.default
    
    init(appSettings: AppSettings, persistenceManager: PersistenceManager) {
        self.appSettings = appSettings
        self.persistenceManager = persistenceManager
    }
    
    // MARK: - Create ZIP Backup
    func createBackup() -> URL? {
        print("Starting backup process...")

        // Step 1: Create JSON Backup
        guard let backupData = createJSONBackup() else {
            print("Failed to create JSON backup")
            return nil
        }
        print("Successfully created JSON backup.")
        
        // Step 2: Get the Syllabuses directory path
        let syllabusDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Syllabuses")
        print("Syllabus directory path: \(syllabusDirectory.path)")
        
        // Step 3: Ensure the Syllabuses directory exists
        ensureSyllabusesDirectoryExists()

        // Step 4: Create a temporary directory for the backup
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            print("Created temporary directory at: \(tempDir.path)")
        } catch {
            print("Failed to create temp directory: \(error)")
            return nil
        }

        // Step 5: Write the JSON backup to the temp directory
        let jsonBackupURL = tempDir.appendingPathComponent("Backup.json")
        do {
            try backupData.write(to: jsonBackupURL)
            print("Successfully wrote JSON backup to: \(jsonBackupURL.path)")
        } catch {
            print("Failed to write JSON to temp directory: \(error)")
            return nil
        }

        // Step 6: Create a ZIP file in the temp directory
        let zipURL = tempDir.appendingPathComponent("Backup.zip")
        do {
            guard let archive = Archive(url: zipURL, accessMode: .create) else {
                print("Failed to create archive")
                return nil
            }
            
            // Step 7: Add the JSON backup to the archive
            try archive.addEntry(with: "Backup.json", fileURL: jsonBackupURL)
            print("Added JSON backup to the ZIP archive.")
            
            // Step 8: Add the Syllabuses directory to the archive if it exists
            if fileManager.fileExists(atPath: syllabusDirectory.path) {
                print("Syllabus directory exists. Adding to archive...")
                try fileManager.zipDirectory(at: syllabusDirectory, into: archive, directoryName: "Syllabuses")
                print("Added syllabus directory to ZIP archive.")
            } else {
                print("Syllabus directory does not exist. Skipping...")
            }

            print("Backup ZIP successfully created at: \(zipURL.path)")
            return zipURL
        } catch {
            print("Failed to create ZIP archive: \(error)")
            return nil
        }
    }
    
    // MARK: - Restore from ZIP Backup
    func restoreBackup(from zipURL: URL) {
        print("Starting restore process from: \(zipURL.path)")
        
        // Access security-scoped resource if needed (for external files)
        guard zipURL.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource.")
            return
        }
        defer {
            zipURL.stopAccessingSecurityScopedResource()
        }

        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            print("Created temporary directory for restoring at: \(tempDir.path)")

            try fileManager.unzipItem(at: zipURL, to: tempDir)
            print("Successfully unzipped backup.")

            // Print contents of the unzipped directory for debugging
            let contents = try fileManager.contentsOfDirectory(atPath: tempDir.path)
            print("Unzipped folder contents: \(contents)")
        } catch {
            print("Failed to unzip backup: \(error)")
            return
        }

        // Check if the Backup.json exists
        let jsonBackupURL = tempDir.appendingPathComponent("Backup.json")
        if let data = try? Data(contentsOf: jsonBackupURL) {
            print("Found Backup.json at: \(jsonBackupURL.path)")
            restoreJSONBackup(from: data)
            print("Restored JSON backup data.")
        } else {
            print("Failed to find JSON backup file.")
        }

        // Restore syllabuses
        let syllabusDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Syllabuses")
        print("Target Syllabuses directory: \(syllabusDirectory.path)")

        if fileManager.fileExists(atPath: syllabusDirectory.path) {
            print("Syllabuses directory already exists at: \(syllabusDirectory.path). Proceeding with file addition.")
        } else {
            do {
                try fileManager.createDirectory(at: syllabusDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Created Syllabuses directory at: \(syllabusDirectory.path)")
            } catch {
                print("Failed to create Syllabuses directory: \(error)")
                return
            }
        }

        let syllabusTempDir = tempDir.appendingPathComponent("Syllabuses")
        do {
            let syllabusFiles = try fileManager.contentsOfDirectory(at: syllabusTempDir, includingPropertiesForKeys: nil)
            print("Found \(syllabusFiles.count) files in the restored Syllabuses directory.")
            for fileURL in syllabusFiles {
                let destinationURL = syllabusDirectory.appendingPathComponent(fileURL.lastPathComponent)
                print("Copying file \(fileURL.lastPathComponent) to \(destinationURL.path)")
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                    print("Replaced existing file: \(destinationURL.path)")
                }
                try fileManager.copyItem(at: fileURL, to: destinationURL)
                print("Restored \(fileURL.lastPathComponent) to \(destinationURL.path)")
            }
            print("Syllabuses restored successfully.")
        } catch {
            print("Failed to restore syllabus files: \(error)")
        }
    }
    
    // MARK: - Helper to Create JSON Backup
    private func createJSONBackup() -> Data? {
        let backupData = UnifiedBackupData(
            schoolName: appSettings.schoolName,
            selectedCalendarName: appSettings.selectedCalendarName,
            chatGPTTone: appSettings.chatGPTTone,
            activePlan: appSettings.activePlan,
            activePlanSteps: appSettings.activePlanSteps,
            savedPlans: appSettings.savedPlans,
            courses: persistenceManager.loadCourses(),
            syllabuses: persistenceManager.listSyllabuses().map { $0.absoluteString }
        )

        do {
            let encodedData = try JSONEncoder().encode(backupData)
            print("Successfully encoded JSON backup data.")
            return encodedData
        } catch {
            print("Failed to encode backup data: \(error)")
            return nil
        }
    }

    // MARK: - Helper to Restore JSON Backup
    private func restoreJSONBackup(from data: Data) {
        do {
            let decodedData = try JSONDecoder().decode(UnifiedBackupData.self, from: data)
            
            // Restore app settings
            appSettings.schoolName = decodedData.schoolName
            appSettings.selectedCalendarName = decodedData.selectedCalendarName
            appSettings.chatGPTTone = decodedData.chatGPTTone
            appSettings.activePlan = decodedData.activePlan
            appSettings.activePlanSteps = decodedData.activePlanSteps
            appSettings.savedPlans = decodedData.savedPlans

            // Restore courses
            let restoredCourses = decodedData.courses
            persistenceManager.saveCourses(restoredCourses)
            
            print("AppSettings and courses restored successfully.")
        } catch {
            print("Failed to restore JSON backup: \(error)")
        }
    }
    
    // MARK: - Ensure Syllabuses Directory Exists
    private func ensureSyllabusesDirectoryExists() {
        let syllabusDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Syllabuses")
        if !fileManager.fileExists(atPath: syllabusDirectory.path) {
            do {
                try fileManager.createDirectory(at: syllabusDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Created Syllabuses directory at: \(syllabusDirectory.path)")
            } catch {
                print("Failed to create Syllabuses directory: \(error)")
            }
        }
    }
}

// MARK: - FileManager Extensions for Zipping Directories
extension FileManager {
    func zipDirectory(at directoryURL: URL, into archive: Archive, directoryName: String) throws {
        let fileEnumerator = enumerator(at: directoryURL, includingPropertiesForKeys: nil)
        while let fileURL = fileEnumerator?.nextObject() as? URL {
            if fileURL.pathExtension == "pdf" {
                let relativePath = "\(directoryName)/\(fileURL.lastPathComponent)"
                try archive.addEntry(with: relativePath, fileURL: fileURL)
                print("Added \(relativePath) to ZIP archive.")
            }
        }
    }
}
