import SwiftUI
import EventKit

enum LearningStyle: String, CaseIterable, Identifiable {
    case adhd = "ADHD"
    case dyslexia = "Dyslexia"
    case both = "Both"
    case none = "None"

    var id: String { self.rawValue }

    var color: Color {
        switch self {
        case .adhd:
            return .orange
        case .dyslexia:
            return .green
        case .both:
            return .blue
        case .none:
            return .purple
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.presentationMode) var presentationMode

    let chatGPTTones = ["Warm and Supportive", "Tough Love", "Sarcastic"]
    @State private var selectedCalendar: EKCalendar?
    @State private var saveButtonText = "Save School Name"
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                // School Name Section
                Section(header: Text("School Information")) {
                    TextField("Name of School", text: $appSettings.schoolName)
                        .padding()
                        .onChange(of: appSettings.schoolName) { _ in
                            saveButtonText = "Save School Name"
                        }

                    Button(saveButtonText) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                        if appSettings.schoolName.isEmpty {
                            showAlert = true
                            alertMessage = "School name cannot be empty."
                        } else {
                            saveButtonText = "Saved"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                saveButtonText = "Edit School Name"
                            }
                        }
                    }
                    .disabled(appSettings.schoolName.isEmpty)
                }

                // Selected Calendar Section
                Section(header: Text("Calendar Selection")) {
                    Picker("Choose Calendar", selection: $selectedCalendar) {
                        ForEach(calendarManager.getCalendars(), id: \.self) { calendar in
                            Text(calendar.title).tag(calendar as EKCalendar?)
                        }
                    }
                    .onChange(of: selectedCalendar) { newValue in
                        if let selectedCalendar = newValue {
                            appSettings.selectedCalendarName = selectedCalendar.title
                        }
                    }

                    if let selectedCalendarName = appSettings.selectedCalendarName {
                        Text("Selected Calendar: \(selectedCalendarName)")
                    }
                }

                // ChatGPT Tone Section
                Section(header: Text("ChatGPT Tone")) {
                    Picker("Motivational Tone", selection: $appSettings.chatGPTTone) {
                        ForEach(chatGPTTones, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Learning Style Section with Color-Coded Text
                Section(header: Text("Learning Style")) {
                    Picker("Select Learning Style", selection: $appSettings.learningStyle) {
                        ForEach(LearningStyle.allCases) { style in
                            Text(style.rawValue)
                                .foregroundColor(style.color)  // Apply color based on the learning style
                                .tag(style.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Backup and Restore Section
                Section(header: Text("Backup and Restore")) {
                    NavigationLink(destination: BackUpView(appSettings: appSettings)) {
                        Text("Backup & Import")
                    }
                }

                // Reset Data Section
                Section(header: Text("Reset Data")) {
                    Button("Reset All Data") {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings V.1 build 1.0.5")
            .navigationBarItems(leading: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showingResetConfirmation) {
                Alert(
                    title: Text("Reset All Data"),
                    message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            if let selectedCalendarName = appSettings.selectedCalendarName {
                selectedCalendar = calendarManager.findCalendar(named: selectedCalendarName)
            }
        }
    }

    private func resetAllData() {
        let persistenceManager = PersistenceManager()
        persistenceManager.clearAllUserDefaults()
        appSettings.resetSettings()
        calendarManager.resetCalendar()
    }
}
