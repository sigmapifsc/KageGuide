import SwiftUI
import PDFKit

struct PDFViewer: View {
    let url: URL
    @Binding var analysisResult: String  // Bind the analysis result
    var onAnalyze: (() -> Void)?
    
    @State private var showSummary = false  // Control showing the summary
    @State private var showCreateSummaryAlert = false  // Show alert for creating summary
    @State private var showSyllabusShareSheet = false  // Control the share sheet
    @State private var isPDFValid = false  // Track whether the PDF is valid for sharing

    var body: some View {
        ZStack(alignment: .bottomTrailing) {  // Use ZStack for overlay button
            VStack {
                PDFKitView(url: url)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        validatePDF()  // Check if the PDF file is valid when the view appears
                    }
                
                if showSummary {
                    VStack {
                        HStack {
                            Text("Syllabus Summary")
                                .font(.headline)
                                .padding()

                            Spacer()

//                            // Button to close the summary
//                            Button(action: {
//                                showSummary.toggle()  // Close the summary
//                            }) {
//                                Text("Close Summary")
//                                    .padding()
//                                    .frame(height: 30)
//                                    .background(Color.indigo)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
                        }

                        ScrollView {
                            Text(analysisResult)
                                .padding()
                        }
                        .frame(maxHeight: .infinity)  // Make the summary fill the screen
                    }
                    .transition(.slide)  // Add a nice transition when showing the summary
                }
            }

            // Floating button for View/Create/Close Summary
            Button(action: {
                if analysisResult.isEmpty {
                    showCreateSummaryAlert = true  // Trigger creation if no summary exists
                } else {
                    showSummary.toggle()  // Toggle showing/hiding the summary
                }
            }) {
                // Update button text based on whether a summary exists
                Text(analysisResult.isEmpty ? "Create Summary" : (showSummary ? "Close Summary" : "View Summary"))
                    .padding()
                    .frame(height: 30)

                    .background(analysisResult.isEmpty ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding()  // Position the floating button
            .alert(isPresented: $showCreateSummaryAlert) {
                Alert(
                    title: Text("Create Summary"),
                    message: Text("Would you like to analyze the syllabus and create a summary?"),
                    primaryButton: .default(Text("Yes"), action: {
                        onAnalyze?()  // Call the analyze action
                    }),
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showSyllabusShareSheet) {
                if isPDFValid {
                    ActivityView(activityItems: [analysisResult, url])
                } else {
                    ActivityView(activityItems: [analysisResult])
                }
            }
        }
        .onAppear {
            // Ensure the button state is set based on whether an analysisResult exists
            if !analysisResult.isEmpty {
                showSummary = false  // Reset summary view if result exists
            }
        }
    }

    // Function to validate if the PDF exists and is accessible
    private func validatePDF() {
        if FileManager.default.fileExists(atPath: url.path) {
            isPDFValid = true
        } else {
            print("Error: The file \(url.lastPathComponent) couldn't be opened.")
            isPDFValid = false
        }
    }

    // Function to share the summary
    private func shareSummary() {
        if isPDFValid {
            print("Sharing PDF and summary.")
        } else {
            print("Sharing summary only.")
        }
        showSyllabusShareSheet = true
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}

// Activity View Controller for sharing the PDF and summary
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
