import SwiftUI

struct PlanArchiveView: View {
    @Binding var archivedPlans: [Plan]
    var onUnarchive: (Plan) -> Void
    @Environment(\.presentationMode) var presentationMode  // Dismiss the view

    var body: some View {
        NavigationView {  // Added NavigationView for the close button in the toolbar
            List {
                ForEach(archivedPlans) { plan in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(plan.title)
                        }

                        Spacer()

                        Button(action: {
                            onUnarchive(plan)
                        }) {
                            Image(systemName: "arrow.uturn.left.circle")
                                .foregroundColor(.green)
                        }
                        .padding(.trailing, 15)

                        Button(action: {
                            deletePlan(plan)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Archived Plans")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the modal
                    }
                }
            }
        }
    }

    private func deletePlan(_ plan: Plan) {
        archivedPlans.removeAll { $0.id == plan.id }
    }
}

struct PlanArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        PlanArchiveView(archivedPlans: .constant([Plan(title: "Plan 1", steps: [], isActive: false)]), onUnarchive: { _ in })
    }
}
