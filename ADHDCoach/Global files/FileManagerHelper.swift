//
//  FileManagerHelper.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/23/24.
//

import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init() {}
    
    // Saves a PDF for a course
    func savePDF(from url: URL, courseName: String) -> URL? {
        let destinationFilename = "\(courseName)_\(url.lastPathComponent)"
        let syllabusesDirectory = documentsDirectory.appendingPathComponent("Syllabuses")
        
        // Ensure the Syllabuses directory exists
        ensureSyllabusesDirectoryExists()

        let destinationURL = syllabusesDirectory.appendingPathComponent(destinationFilename)
        
        do {
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource.")
                return nil
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }

            let data = try Data(contentsOf: url)
            try data.write(to: destinationURL)
            print("Saved PDF at \(destinationURL.path)")
            return destinationURL
        } catch {
            print("Error saving file: \(error.localizedDescription)")
            return nil
        }
    }

    // Lists all PDF files in the "Syllabuses" directory within the documents directory
    func listPDFFiles() -> [URL] {
        let syllabusesDirectory = documentsDirectory.appendingPathComponent("Syllabuses")

        do {
            let urls = try FileManager.default.contentsOfDirectory(at: syllabusesDirectory, includingPropertiesForKeys: nil)
            let pdfFiles = urls.filter { $0.pathExtension == "pdf" }
            print("Found PDF files in Syllabuses directory: \(pdfFiles)")  // Debugging: List found files
            return pdfFiles
        } catch {
            print("Error listing files in Syllabuses directory: \(error.localizedDescription)")
            return []
        }
    }
    
    // Deletes a PDF from the documents directory
    func deletePDF(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Deleted file: \(url.path)")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }

    // Backup syllabuses (PDFs) to a backup directory
    func backupSyllabuses() -> URL {
        let syllabusesDirectory = documentsDirectory.appendingPathComponent("Syllabuses")

        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: syllabusesDirectory.path) {
            try? FileManager.default.createDirectory(at: syllabusesDirectory, withIntermediateDirectories: true, attributes: nil)
            print("Created Syllabuses directory at: \(syllabusesDirectory.path)")
        }

        // List all PDF files and copy them to the Syllabuses folder
        let pdfFiles = listPDFFiles()
        for file in pdfFiles {
            let destinationURL = syllabusesDirectory.appendingPathComponent(file.lastPathComponent)
            try? FileManager.default.copyItem(at: file, to: destinationURL)
            print("Copied file to \(destinationURL.path)")
        }

        return syllabusesDirectory
    }

    // Restores syllabuses (PDFs) from a backup directory
    func restoreSyllabuses() {
        let syllabusesDirectory = documentsDirectory.appendingPathComponent("Syllabuses")
        
        // Check if the backup syllabuses folder exists
        if FileManager.default.fileExists(atPath: syllabusesDirectory.path) {
            let backupSyllabuses = listPDFFiles(in: syllabusesDirectory)
            
            // Restore PDFs to the main documents directory
            for file in backupSyllabuses {
                let destinationURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
                try? FileManager.default.copyItem(at: file, to: destinationURL)
                print("Restored file to \(destinationURL.path)")
            }
        } else {
            print("No backup syllabuses directory found.")
        }
    }

    // Lists PDF files in a specific directory
    func listPDFFiles(in directory: URL) -> [URL] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return urls.filter { $0.pathExtension == "pdf" }
        } catch {
            print("Error listing PDF files in directory \(directory): \(error.localizedDescription)")
            return []
        }
    }
    
    // Ensure the Syllabuses directory exists
    private func ensureSyllabusesDirectoryExists() {
        let syllabusesDirectory = documentsDirectory.appendingPathComponent("Syllabuses")
        if !FileManager.default.fileExists(atPath: syllabusesDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: syllabusesDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Created Syllabuses directory at: \(syllabusesDirectory.path)")
            } catch {
                print("Failed to create Syllabuses directory: \(error.localizedDescription)")
            }
        }
    }
}
