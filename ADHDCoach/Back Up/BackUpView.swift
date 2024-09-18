//
//  BackUpView.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/7/24.
//
// BackUpView.swift


import SwiftUI
import UniformTypeIdentifiers

struct BackUpView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingFileExporter = false
    @State private var showingFileImporter = false
    @State private var exportURL: URL?
    @State private var importErrorAlert = false
    @State private var importErrorMessage = ""

    var persistenceManager = PersistenceManager()
    var backupManager: BackupManager

    init(appSettings: AppSettings) {
        self.backupManager = BackupManager(appSettings: appSettings, persistenceManager: persistenceManager)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Backup and Import")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(height: 30)


            // Export Button
            Button(action: {
                exportData()
            }) {
                Text("Export to Backup")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .fileExporter(
                isPresented: $showingFileExporter,
                document: BackupFile(initialURL: exportURL),
                contentType: .zip, // Ensure we're exporting as a .zip
                defaultFilename: "KageBackUp.zip", // Use the .zip extension
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        print("Backup saved to: \(url)")
                    case .failure(let error):
                        print("Error exporting: \(error.localizedDescription)")
                    }
                }
            )

            // Import Button
            Button(action: {
                showingFileImporter = true
            }) {
                Text("Import from Backup")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [UTType.zip], // Importing from a .zip
                allowsMultipleSelection: false,
                onCompletion: handleFileImport
            )
        }
        .padding()
        .alert(isPresented: $importErrorAlert) {
            Alert(title: Text("Import Error"), message: Text(importErrorMessage), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Export Data
    func exportData() {
        if let backupURL = backupManager.createBackup() {  // Create a backup and get the URL of the zip file
            exportURL = backupURL  // Use the URL for the file exporter
            showingFileExporter = true
        }
    }

    // MARK: - Handle File Import
    func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFile = try result.get().first
            if let selectedFile = selectedFile {
                backupManager.restoreBackup(from: selectedFile)  // Restore from the URL of the selected file
            }
        } catch {
            importErrorMessage = error.localizedDescription
            importErrorAlert = true
        }
    }
}

// Helper struct for File Exporter
struct BackupFile: FileDocument {
    static var readableContentTypes: [UTType] { [.zip] }  // Exporting as .zip

    var initialURL: URL?

    init(initialURL: URL? = nil) {
        self.initialURL = initialURL
    }

    init(configuration: ReadConfiguration) throws {
        // No additional configuration required
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let initialURL = initialURL else {
            throw CocoaError(.fileNoSuchFile)
        }
        let fileData = try Data(contentsOf: initialURL)  // Read data from the initial URL
        return FileWrapper(regularFileWithContents: fileData)
    }
}
