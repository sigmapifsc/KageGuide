//
//  ShareSheet.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/8/24.
//

//  ShareSheet.swift
//  ADHDCoach (or your app name)

import SwiftUI
import UIKit

// Rename the existing ShareSheet related to syllabus sharing
struct SyllabusShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Debugging when the share sheet is presented
        print("ShareSheet is being presented with items: \(items)")
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Debugging when the share sheet is updated
        print("ShareSheet updated.")
    }
}
