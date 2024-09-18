import SwiftUI

struct CrisisPlanView: View {
    @State private var userInput: String = ""
    @State private var crisisPlan: String? = nil
    @State private var isLoading: Bool = false
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var viewModel: CoursesViewModel
    @Binding var selectedTab: Int  // Bind to the selectedTab so we can navigate to the dashboard
    @Environment(\.dismiss) private var dismiss  // Add dismiss environment action

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Create a Crisis Plan")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                TextField("Tell me what's going on", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top)

                Button(action: {
                    generateCrisisPlan()
                }) {
                    Text("Create Crisis Plan")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)

                if isLoading {
                    ProgressView("ShadowGuide is analyzing all of your work...")
                        .padding(.top)
                }

                if let plan = crisisPlan {
                    Text("Your Crisis Plan")
                        .font(.title2)
                        .padding(.top)

                    ScrollView {
                        Text(plan)
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .frame(minHeight: 200)
                }

                Button(action: {
                    activatePlan()
                }) {
                    Text("Activate Plan")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .onAppear {
            print("CrisisPlanView appeared.")
            print("Saved Plans Count: \(appSettings.savedPlans.count)")
            print("Is Active Plan: \(appSettings.isPlanActive)")
        }
    }
    
    func generateCrisisPlan() {
        print("Generating crisis plan...")
        isLoading = true  // Start loading indicator

        // Use courses from viewModel and appSettings
        CrisisLogic.generateCrisisPlan(userInput: userInput, courses: viewModel.courses, appSettings: appSettings) { response in
            DispatchQueue.main.async {
                print("Crisis plan generated: \(response)")
                self.crisisPlan = response
                self.isLoading = false  // Stop loading indicator
            }
        }
    }
    
    func activatePlan() {
        guard let crisisPlan = crisisPlan else {
            print("No crisis plan available to activate.")
            return
        }

        let steps = crisisPlan.components(separatedBy: "\n").filter { !$0.isEmpty }
        let newPlan = Plan(title: "Crisis Plan", steps: steps, isActive: true)
        
        print("Plan created: \(newPlan.title) with \(newPlan.steps.count) steps.")
        
        appSettings.activePlan = newPlan
        appSettings.savedPlans.append(newPlan)
        appSettings.isPlanActive = true
        
        print("Plan activated. Active plan title: \(appSettings.activePlan?.title ?? "None")")

        // Close the current sheet/modal
        dismiss()  // This closes the modal view

        // After saving and activating, set the tab to Dashboard (assuming index 0 is the Dashboard tab)
        selectedTab = 0
    }
}
