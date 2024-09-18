import SwiftUI
import PDFKit

struct ImportView: View {
    @Binding var courses: [Course]
    @ObservedObject var viewModel: CoursesViewModel
    
    @State private var isDocumentPickerPresented = false
    @State private var selectedCourse: Course?
    @State private var showingAddCourseSheet = false
    @State private var newCourseName = ""
    @State private var newCourseSchedule: [ScheduleItem] = []
    @State private var newCourseColor = Color.blue
    @State private var newCourseLocation = ""
    @State private var newCoursePortalLink: String = ""
    @State private var importedFiles: [URL] = []
    @State private var showAlert = false
    @State private var fileToDelete: URL?
    @State private var analysisResults: [String] = []
    @State private var analyzedFiles: Set<URL> = []
    @State private var isLoading = false
    @State private var analysisResult: String = ""  // Store the analysis result
    
    @EnvironmentObject var appSettings: AppSettings
    
    private let openAIService = OpenAIService()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Analyzing Syllabus...")
                        .padding()
                } else {
                    Picker("Select a Course", selection: $selectedCourse) {
                        ForEach(courses, id: \.id) { course in
                            Text(course.name).tag(course as Course?)
                        }
                        Text("Select Course").tag(nil as Course?)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    if selectedCourse == nil {
                        Button(action: {
                            showingAddCourseSheet = true
                        }) {
                            Text("Add New Course")
                                .padding()
                                .frame(height: 30)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showingAddCourseSheet) {
                            AddCourseView(
                                courseName: $newCourseName,
                                selectedColor: $newCourseColor,
                                courseLocation: $newCourseLocation,
                                courseSchedule: $newCourseSchedule,
                                portalLink: $newCoursePortalLink,
                                onSave: {
                                    let newCourse = Course(
                                        name: newCourseName,
                                        courseSchedule: newCourseSchedule,
                                        courseColor: newCourseColor.description,
                                        courseLocation: newCourseLocation,
                                        portalLink: URL(string: newCoursePortalLink),
                                        assignments: []
                                    )
                                    courses.append(newCourse)
                                    selectedCourse = newCourse
                                    newCourseName = ""
                                    newCourseColor = Color.blue
                                    newCourseLocation = ""
                                    newCourseSchedule = []
                                    newCoursePortalLink = ""
                                    viewModel.saveCourses()
                                }
                            )
                        }
                    }
                    
                    Button(action: {
                        isDocumentPickerPresented = true
                    }) {
                        Text("Import Syllabus PDF")
                            .padding()
                            .frame(height: 30)
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedCourse == nil)
                    .sheet(isPresented: $isDocumentPickerPresented) {
                        DocumentPicker { url in
                            if let url = url, let course = selectedCourse {
                                if let savedURL = FileManagerHelper.shared.savePDF(from: url, courseName: course.name) {
                                    importedFiles.append(savedURL)
                                    analyzedFiles.insert(savedURL)
                                }
                            }
                        }
                    }
                    
                    List {
                        if let course = selectedCourse {
                            let courseFiles = importedFiles.filter { $0.lastPathComponent.contains(course.name) }
                            if courseFiles.isEmpty {
                                Text("No syllabuses found for this course.")
                            } else {
                                ForEach(courseFiles, id: \.self) { fileURL in
                                    HStack {
                                        NavigationLink(destination: PDFViewer(
                                            url: fileURL,
                                            analysisResult: Binding(
                                                get: { analysisResults.first(where: { $0 == fileURL.lastPathComponent }) ?? "" },
                                                set: { analysisResult in
                                                    if let index = analysisResults.firstIndex(where: { $0 == fileURL.lastPathComponent }) {
                                                        analysisResults[index] = analysisResult
                                                    }
                                                }
                                            ),
                                            onAnalyze: {
                                                analyzePDF(at: fileURL)
                                            }
                                        )) {
                                            VStack(alignment: .leading) {
                                                Text(fileURL.lastPathComponent.prefix(20) + "...")
                                                    .font(.subheadline)  // Reduce font size and truncate title
                                                    .lineLimit(1)  // Ensure single line display
                                            }
                                        }
                                        Spacer()
                                        
                                        // Check if there is a saved summary
                                        if let courseIndex = courses.firstIndex(where: { $0.id == selectedCourse?.id }),
                                           let analysisResult = courses[courseIndex].analysisResults, !analysisResult.isEmpty {
                                            Button(action: {
                                                navigateToSummaryView(for: course)  // Navigate to summary view
                                            }) {
                                                Image(systemName: "doc.text")
                                                Text("View Summary")
                                                    .font(.caption)  // Smaller font for button
                                            }
                                        }
                                        
                                        Button(action: {
                                            sharePDF(at: fileURL)
                                        }) {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        Button(action: {
                                            fileToDelete = fileURL
                                            showAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        } else {
                            Text("Select a course to view its syllabuses.")
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Import Syllabus")
            .onAppear {
                importedFiles = FileManagerHelper.shared.listPDFFiles()
                viewModel.loadCourses()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Syllabus"),
                    message: Text("Are you sure you want to delete this syllabus? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let url = fileToDelete {
                            deletePDF(at: url)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func deletePDF(at url: URL) {
        FileManagerHelper.shared.deletePDF(at: url)
        importedFiles.removeAll { $0 == url }
    }
    
    private func sharePDF(at url: URL) {
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let topController = UIApplication.shared.connectedScenes
            .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
            .first(where: { $0.isKeyWindow })?.rootViewController {
            topController.present(activityView, animated: true, completion: nil)
        }
    }
    
    private func analyzePDF(at url: URL) {
        guard let pdfText = parsePDF(from: url) else {
            print("Failed to parse PDF")
            return
        }

        let truncatedText = String(pdfText.prefix(12000))

        isLoading = true

        // Use the correct centralized prompt from Prompts.swift
        // Start replacement code here
        let prompt: String
        switch appSettings.learningStyle {
            case LearningStyle.adhd.rawValue:
                prompt = Prompts.adhdSyllabusAnalysisPrompt(syllabusText: truncatedText)
            case LearningStyle.dyslexia.rawValue:
                prompt = Prompts.dyslexiaSyllabusAnalysisPrompt(syllabusText: truncatedText)
            case LearningStyle.both.rawValue:
                prompt = Prompts.bothSyllabusAnalysisPrompt(syllabusText: truncatedText)
            default:
                prompt = Prompts.noneSyllabusAnalysisPrompt(syllabusText: truncatedText)
        }
        // End of replacement code
        openAIService.generateStrategyAndMotivation(prompt: prompt) { result in
            DispatchQueue.main.async {
                if let analysisResult = try? result.get().strategy {
                    print("API Response: \(analysisResult)")
                    self.analysisResults.append(analysisResult)

                    if let selectedCourse = self.selectedCourse, let index = self.courses.firstIndex(where: { $0.id == selectedCourse.id }) {
                        self.courses[index].analysisResults = analysisResult
                        self.viewModel.saveCourses()
                    }
                } else {
                    print("No analysis result")
                    self.analysisResults.append("No analysis result")
                }

                self.isLoading = false
            }
        }
    }
    
    private func navigateToSummaryView(for course: Course) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == course.id }),
              let analysisResult = courses[courseIndex].analysisResults else {
            print("No summary available")
            return
        }

        let summaryView = SyllabusSummaryView(
            courseTitle: course.name,
            summary: analysisResult,
            onSave: {
                self.viewModel.saveCourses()
            },
            onClose: {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        )

        let summaryViewController = UIHostingController(rootView: summaryView)
        UIApplication.shared.windows.first?.rootViewController?.present(summaryViewController, animated: true, completion: nil)
    }

    private func parsePDF(from url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else { return nil }
        var fullText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageContent = page.string {
                fullText += pageContent + "\n"
            }
        }
        return fullText
    }
}
