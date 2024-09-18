import SwiftUI

struct AddCourseView: View {
    @Binding var courseName: String
    @Binding var selectedColor: Color
    @Binding var courseLocation: String
    @Binding var courseSchedule: [ScheduleItem]
    @Binding var portalLink: String
    @State private var resources: [String] = []
    @State private var newResourceURL: String = ""

    @Environment(\.presentationMode) var presentationMode
    var onSave: () -> Void

    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        NavigationView {
            Form {
                TextField("Course Name", text: $courseName)

                TextField("Course Location", text: $courseLocation)

                Section(header: Text("Course Schedule")) {
                    ForEach(courseSchedule.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            HStack {
                                Picker("Day", selection: Binding(
                                    get: { courseSchedule[index].day ?? "Monday" },
                                    set: { courseSchedule[index].day = $0 }
                                )) {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day).tag(day)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())

                                Button(action: {
                                    removeScheduleItem(at: index)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }

                            HStack {
                                DatePicker("Start Time", selection: $courseSchedule[index].startTime, displayedComponents: [.hourAndMinute])
                                    .onChange(of: courseSchedule[index].startTime) { newStartTime in
                                        if courseSchedule[index].endTime <= newStartTime {
                                            courseSchedule[index].endTime = newStartTime.addingTimeInterval(3600)
                                        }
                                    }

                                DatePicker("End Time", selection: $courseSchedule[index].endTime, displayedComponents: [.hourAndMinute])
                            }
                        }
                    }

                    Button(action: {
                        addScheduleItem()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                        }
                    }
                }

                TextField("Portal Link", text: $portalLink)
                    .keyboardType(.URL)
                    .autocapitalization(.none)

                Section(header: Text("Resources")) {
                    ForEach(resources, id: \.self) { resource in
                        Text(resource)
                    }
                    
                    TextField("New Resource URL", text: $newResourceURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)

                    Button("Add Resource") {
                        addResource()
                    }
                }

                Button("Save") {
                    print("Saving Course with Location: \(courseLocation)")
                    print("Saving Course with Schedule Items: \(courseSchedule)")
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Add Course")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addScheduleItem() {
        if let lastScheduleItem = courseSchedule.last {
            let newDay = getNextDay(from: lastScheduleItem.day ?? "Monday")
            let newScheduleItem = ScheduleItem(day: newDay, startTime: lastScheduleItem.startTime, endTime: lastScheduleItem.endTime)
            courseSchedule.append(newScheduleItem)
        } else {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = 9
            components.minute = 30
            let defaultStartTime = calendar.date(from: components) ?? Date()

            courseSchedule.append(ScheduleItem(day: daysOfWeek[0], startTime: defaultStartTime, endTime: defaultStartTime.addingTimeInterval(3600)))
        }
    }

    private func removeScheduleItem(at index: Int) {
        courseSchedule.remove(at: index)
    }

    private func addResource() {
        // Add only if the URL is not empty
        if !newResourceURL.isEmpty {
            resources.append(newResourceURL)
            newResourceURL = "" // Clear the input field after adding the resource
        }
    }

    private func getNextDay(from day: String) -> String {
        if let currentIndex = daysOfWeek.firstIndex(of: day), currentIndex < daysOfWeek.count - 1 {
            return daysOfWeek[currentIndex + 1]
        } else {
            return daysOfWeek[0]
        }
    }
}
