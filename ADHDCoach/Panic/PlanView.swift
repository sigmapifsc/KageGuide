import SwiftUI

struct PlanView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var archivedPlans: [Plan] = []  // State for archived plans
    @State private var selectedPlan: Plan?  // Store the selected plan
    @State private var showingPlanDetail = false
    @State private var showArchiveView = false  // State to show the archive view
    @Environment(\.presentationMode) var presentationMode  // Dismiss the view

    var body: some View {
        NavigationView {  // Added NavigationView for toolbar and close button
            VStack {
                Text("Here is a list of all your plans.")
                    .padding()

                if appSettings.savedPlans.isEmpty {
                    Text("No plans available.")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(appSettings.savedPlans) { plan in
                            HStack {
                                NavigationLink(destination: PlanDetailView(plan: plan)) {
                                    Text(plan.title)
                                }
                                Spacer()

                                // Archive button
                                Button(action: {
                                    archivePlan(plan)
                                }) {
                                    Image(systemName: "tray.and.arrow.down.fill")
                                        .foregroundColor(.orange)
                                }
                                .buttonStyle(BorderlessButtonStyle())

                                // Delete button
                                Button(action: {
                                    deletePlan(plan)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }

                // Show archived plans button
                Button(action: {
                    showArchiveView = true
                }) {
                    Text("View Archived Plans")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showArchiveView) {
                    PlanArchiveView(archivedPlans: $archivedPlans, onUnarchive: { plan in
                        unarchivePlan(plan)
                    })
                }
                .padding(.top)
            }
            .navigationTitle("Plans")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the view
                    }
                }
            }
            .onAppear {
                loadPlans()
                loadArchivedPlans()
            }
        }
    }

    // Archive a plan
    private func archivePlan(_ plan: Plan) {
        if let index = appSettings.savedPlans.firstIndex(where: { $0.id == plan.id }) {
            archivedPlans.append(appSettings.savedPlans.remove(at: index))
            savePlans()
        }
    }

    // Delete a plan
    private func deletePlan(_ plan: Plan) {
        appSettings.savedPlans.removeAll { $0.id == plan.id }
        savePlans()
    }

    // Unarchive a plan
    private func unarchivePlan(_ plan: Plan) {
        if let index = archivedPlans.firstIndex(where: { $0.id == plan.id }) {
            appSettings.savedPlans.append(archivedPlans.remove(at: index))
            savePlans()
        }
    }

    // Load saved plans and archived plans
    private func loadPlans() {
        if let savedPlansData = UserDefaults.standard.data(forKey: "savedPlans"),
           let decodedPlans = try? JSONDecoder().decode([Plan].self, from: savedPlansData) {
            appSettings.savedPlans = decodedPlans
        }
    }

    private func loadArchivedPlans() {
        if let archivedPlansData = UserDefaults.standard.data(forKey: "archivedPlans"),
           let decodedArchivedPlans = try? JSONDecoder().decode([Plan].self, from: archivedPlansData) {
            archivedPlans = decodedArchivedPlans
        }
    }

    // Save both active and archived plans
    private func savePlans() {
        if let encodedPlans = try? JSONEncoder().encode(appSettings.savedPlans) {
            UserDefaults.standard.set(encodedPlans, forKey: "savedPlans")
        }

        if let encodedArchivedPlans = try? JSONEncoder().encode(archivedPlans) {
            UserDefaults.standard.set(encodedArchivedPlans, forKey: "archivedPlans")
        }
    }
}
