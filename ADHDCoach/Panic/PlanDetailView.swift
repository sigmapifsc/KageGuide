import SwiftUI
import UIKit

struct PlanDetailView: View {
    var plan: Plan
    @EnvironmentObject var appSettings: AppSettings
    @State private var isPlanActive: Bool = false
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view
    @State private var showingShareSheet = false  // State to control the share sheet

    var body: some View {
        VStack {
            Text("Plan Details for \(plan.title)")
                .font(.title)
                .padding()
            
            Toggle(isOn: $isPlanActive) {
                Text(isPlanActive ? "Plan is Active" : "Plan is Inactive")
                    .font(.headline)
                    .foregroundColor(isPlanActive ? .green : .red)
            }
            .padding()
            .onChange(of: isPlanActive) { newValue in
                appSettings.isPlanActive = newValue
                if newValue {
                    appSettings.activePlan = plan
                    print("Plan \(plan.title) set as active.")
                } else {
                    appSettings.activePlan = nil
                    print("Plan \(plan.title) deactivated.")
                }
            }
            
            List(plan.steps, id: \.self) { step in
                Text(step)
            }

            // Send Plan Button
            Button(action: {
                showingShareSheet = true  // Trigger the share sheet
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")  // Send icon
                        .foregroundColor(.blue)
                    Text("Send Plan")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
        }
        .onAppear {
            isPlanActive = appSettings.activePlan?.title == plan.title
            print("PlanDetailView appeared for \(plan.title). Is Active: \(isPlanActive)")
        }
        .navigationBarTitle("Plan Details", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()  // Dismiss the view
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(activityItems: [formatPlanForSharing()])  // Use the share sheet to send the plan
        }
    }

    // Format the plan content for sharing
    private func formatPlanForSharing() -> String {
        var content = "Plan: \(plan.title)\n\n"
        content += "Steps:\n"
        for (index, step) in plan.steps.enumerated() {
            content += "\(index + 1). \(step)\n"
        }
        return content
    }
}

// Share Sheet View Controller for sharing the plan
struct ShareSheetView: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
