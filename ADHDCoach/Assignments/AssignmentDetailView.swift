import SwiftUI
import UIKit

struct AssignmentDetailView: View {
    @State var assignment: Assignment
    @State private var showingEditAssignmentSheet = false  // For the Edit Assignment sheet
    @State private var showingShareSheet = false
    @State private var strategy: String = ""
    @State private var motivation: String = ""
    @State private var isLoading = false
    @State private var isSummaryExpanded = false  // For collapsible summary
    @State private var isStrategyExpanded = false // For collapsible strategy
    @State private var isShowingFeedbackSheet = false // For user feedback on "Try Again"
    @State private var feedbackText = "" // For capturing user feedback
    @EnvironmentObject var appSettings: AppSettings

    private let openAIService = OpenAIService()

    var body: some View {
        VStack(spacing: 5) {  // Reduced spacing between toolbar and content
            // Top Bar with Assignment Title, Due Date
            VStack(alignment: .leading, spacing: 5) { // Reduced spacing between title and content
                HStack {
                    VStack(alignment: .leading) {
                        Text(assignment.title)
                            .font(.title3) // Reduced size to title2
                            .fontWeight(.bold)

                        Text("\(daysLeft(until: assignment.dueDate))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)

                        // Due date, smaller and less noticeable
                        Text("Due: \(formattedDate(assignment.dueDate))")
                            .font(.caption)
                            .foregroundColor(.gray)

                        // New Strategy Button
                        NavigationLink(destination: FeedbackPage(feedbackText: $feedbackText, onSubmit: {
                            print("Submit button tapped, feedback: \(feedbackText)")
                            generateStrategyWithFeedback()
                        })) {
                            Text("New Strategy")
                                .padding()
                                .frame(height: 30)
                                .background(Color.indigo)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)

            // Scrollable Content Section
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Summary:")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isSummaryExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isSummaryExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.indigo)
                            }
                        }
                        if isSummaryExpanded {
                            ScrollView {
                                Text(assignment.details)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                    }

                    // Step-by-Step Strategy Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Step-by-Step Strategy:")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isStrategyExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isStrategyExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.indigo)
                            }
                        }

                        if isLoading {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Analyzing assignment...")
                                        .foregroundColor(.black)
                                    ProgressView()
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        } else {
                            if isStrategyExpanded {
                                Text(strategy)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .lineLimit(nil)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar {
            // Toolbar with Edit, Close, and Send buttons
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // Edit button
                    Button("Edit") {
                        showingEditAssignmentSheet = true
                    }

                    // Send button
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [generateShareContent()])
        }
        .fullScreenCover(isPresented: $showingEditAssignmentSheet) {
            // Present EditAssignmentView
            EditAssignmentView(
                assignment: Binding(get: { assignment }, set: { assignment = $0 ?? assignment }),
                onSave: {
                    // Save the updated assignment (no argument needed)
                    self.assignment = assignment
                    showingEditAssignmentSheet = false
                }
            )
        }
        .onAppear(perform: loadSavedStrategyAndMotivation)
    }

    // Function to format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // Function to load saved strategy and motivation
    private func loadSavedStrategyAndMotivation() {
        let strategyKey = "strategy_\(assignment.id)"
        let motivationKey = "motivation_\(assignment.id)"

        if let savedStrategy = UserDefaults.standard.string(forKey: strategyKey),
           let savedMotivation = UserDefaults.standard.string(forKey: motivationKey) {
            strategy = savedStrategy
            motivation = savedMotivation
        } else {
            generateStrategyAndMotivation()
        }
    }

    // Function to generate strategy and motivation using OpenAI
    private func generateStrategyAndMotivation() {
        isLoading = true

        let prompt: String
        switch appSettings.learningStyle {
        case LearningStyle.adhd.rawValue:
            prompt = Prompts.assignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        case LearningStyle.dyslexia.rawValue:
            prompt = Prompts.dyslexiaAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        case LearningStyle.both.rawValue:
            prompt = Prompts.bothAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        default:
            prompt = Prompts.noneAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        }

        openAIService.generateStrategyAndMotivation(prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.strategy = response.strategy
                    self.motivation = response.motivation
                    self.saveStrategyAndMotivation()
                case .failure(let error):
                    self.strategy = "Failed to generate strategy. Error: \(error.localizedDescription)"
                    self.motivation = "Failed to generate motivation."
                }
                self.isLoading = false
            }
        }
    }

    // Function to generate strategy with user feedback
    func generateStrategyWithFeedback() {
        isLoading = true

        let prompt: String
        switch appSettings.learningStyle {
        case LearningStyle.adhd.rawValue:
            prompt = Prompts.assignmentStrategyWithFeedback(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details,
                feedback: feedbackText
            )
        case LearningStyle.dyslexia.rawValue:
            prompt = Prompts.dyslexiaAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        case LearningStyle.both.rawValue:
            prompt = Prompts.bothAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        default:
            prompt = Prompts.noneAssignmentStrategy(
                title: assignment.title,
                dueDate: formattedDate(assignment.dueDate),
                details: assignment.details
            )
        }

        openAIService.generateStrategyAndMotivation(prompt: prompt) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.strategy = response.strategy
                    self.motivation = response.motivation
                    self.saveStrategyAndMotivation()
                case .failure(let error):
                    self.strategy = "Failed to generate strategy. Error: \(error.localizedDescription)"
                    self.motivation = "Failed to generate motivation."
                }
                self.isLoading = false
            }
        }
    }

    // Function to save the strategy and motivation
    private func saveStrategyAndMotivation() {
        let strategyKey = "strategy_\(assignment.id)"
        let motivationKey = "motivation_\(assignment.id)"

        UserDefaults.standard.setValue(strategy, forKey: strategyKey)
        UserDefaults.standard.setValue(motivation, forKey: motivationKey)
        print("Strategy and motivation saved for assignment ID: \(assignment.id)")
    }

    // Function to generate the content for sharing
    private func generateShareContent() -> String {
        return """
        Assignment: \(assignment.title)
        Due Date: \(formattedDate(assignment.dueDate))

        Summary:
        \(assignment.details)

        Step-by-Step Strategy:
        \(strategy.isEmpty ? "No strategy generated yet." : strategy)
        """
    }

    // Function to calculate days left until the due date
    private func daysLeft(until dueDate: Date) -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)

        if let days = components.day {
            if days < 0 {
                return "Past Due"
            } else if days == 0 {
                return "Due Today"
            } else {
                return "\(days) days left"
            }
        } else {
            return "Unknown"
        }
    }
}

/// The ShareSheet structure to allow sharing of the generated strategy
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Preview for the AssignmentDetailView
struct AssignmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AssignmentDetailView(assignment: Assignment(
            title: "Sample Assignment",
            dateAdded: Date(),
            dueDate: Date().addingTimeInterval(86400),
            details: "This is a sample assignment description."
        ))
    }
}
