//
//  DateHelper.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/13/24.
//

import Foundation

func daysLeft(until dueDate: Date) -> String {
    let calendar = Calendar.current
    let currentDate = Date()
    
    let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
    if let days = components.day {
        if days < 0 {
            return "Past Due"
        } else {
            return "\(days) days left"
        }
    } else {
        return "Unknown"
    }
}
func daysLeftAsInt(until dueDate: Date) -> Int {
    let calendar = Calendar.current
    let currentDate = Date()
    
    let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
    return components.day ?? 0  // Return 0 if calculation fails
}
