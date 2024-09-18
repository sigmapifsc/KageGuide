import Foundation
import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()

    @Published var calendarAccessGranted = false
    @Published var reminderAccessGranted = false

    // Request access for Calendar and Reminders
    func requestAccess(completion: @escaping (Bool, Bool) -> Void) {
        // Request access for Calendar events
        eventStore.requestAccess(to: .event) { calendarGranted, error in
            DispatchQueue.main.async {
                print("Calendar access granted: \(calendarGranted)")
                self.calendarAccessGranted = calendarGranted

                // Now request reminder access
                self.requestReminderAccess(completion: completion)
            }
        }
    }

    private func requestReminderAccess(completion: @escaping (Bool, Bool) -> Void) {
        // Request access for Reminders
        eventStore.requestAccess(to: .reminder) { reminderGranted, error in
            if let error = error {
                print("Error requesting reminders access: \(error.localizedDescription)")
            }
            print("Reminder access granted: \(reminderGranted)")
            DispatchQueue.main.async {
                self.reminderAccessGranted = reminderGranted
                completion(self.calendarAccessGranted, self.reminderAccessGranted)
            }
        }
    }

    func findCalendar(named name: String) -> EKCalendar? {
        let calendars = eventStore.calendars(for: .event)
        return calendars.first { $0.title == name }
    }

    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    func eventExists(title: String, dueDate: Date, inCalendar calendar: EKCalendar) -> EKEvent? {
        let predicate = eventStore.predicateForEvents(withStart: dueDate.addingTimeInterval(-3600), end: dueDate.addingTimeInterval(3600), calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        return existingEvents.first { $0.title == title && $0.startDate == dueDate }
    }

    func addOrUpdateEvent(title: String, dueDate: Date, notes: String?, toCalendarWithName calendarName: String, eventIdentifier: String?) -> String? {
        guard calendarAccessGranted else {
            print("Calendar access denied.")
            return nil
        }

        guard let calendar = findCalendar(named: calendarName) else {
            print("Calendar with name \(calendarName) not found.")
            return nil
        }

        let event: EKEvent
        if let identifier = eventIdentifier, let existingEvent = eventStore.event(withIdentifier: identifier) {
            event = existingEvent
            print("Updating existing event: \(title)")
        } else if let existingEvent = eventExists(title: title, dueDate: dueDate, inCalendar: calendar) {
            event = existingEvent
            print("Updating event found in calendar: \(title)")
        } else {
            event = EKEvent(eventStore: eventStore)
            print("Creating new event: \(title)")
        }

        event.title = title
        event.startDate = dueDate
        event.endDate = dueDate.addingTimeInterval(3600) // 1-hour duration
        event.notes = notes ?? "No additional notes"
        event.calendar = calendar

        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event successfully saved to calendar \(calendarName).")
            return event.eventIdentifier
        } catch {
            print("Error saving event: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteEvent(withIdentifier identifier: String) {
        guard calendarAccessGranted else {
            print("Calendar access denied.")
            return
        }

        if let event = eventStore.event(withIdentifier: identifier) {
            do {
                try eventStore.remove(event, span: .thisEvent)
                print("Event successfully deleted: \(event.title ?? "")")
            } catch {
                print("Error deleting event: \(error.localizedDescription)")
            }
        } else {
            print("Event with identifier \(identifier) not found.")
        }
    }

    // Modified to log more details when adding a reminder
    func addReminder(title: String, dueDate: Date, notes: String?) {
        print("Adding reminder with title: \(title), dueDate: \(dueDate), notes: \(notes ?? "None")")
        guard reminderAccessGranted else {
            print("Reminders access denied.")
            return
        }

        guard let defaultReminderCalendar = eventStore.defaultCalendarForNewReminders() else {
            print("No default calendar set for reminders.")
            return
        }

        print("Using default reminder calendar: \(defaultReminderCalendar.title)")

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.calendar = defaultReminderCalendar

        let alarm = EKAlarm(absoluteDate: dueDate)
        reminder.addAlarm(alarm)

        do {
            try eventStore.save(reminder, commit: true)
            print("Reminder successfully saved: \(reminder.title ?? "Unknown Title")")
        } catch {
            print("Error saving reminder: \(error.localizedDescription)")
        }
    }

    // Method to reset calendar settings
    func resetCalendar() {
        calendarAccessGranted = false
        reminderAccessGranted = false
        // Add any other reset logic related to calendars here
        print("Calendar settings have been reset.")
    }
}
