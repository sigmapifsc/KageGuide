//
//  AboutView.swift
//  KageGuide
//
//  Created by Ethan Becker on 9/1/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {  // Making the content scrollable
            VStack(alignment: .leading, spacing: 20) {
                Text("About KageGuide")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.indigo)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                Text("""
                    KageGuide is your personal companion on the journey to academic success. In Japanese, “Kage” means “shadow” or “behind the scenes,” symbolizing a supportive presence that works tirelessly in the background. Just like a shadow that follows you everywhere, KageGuide is designed to be your ever-present, silent partner, helping you master focus and conquer tasks.
                    
                    NEVER QUIT! No matter what.  Even when it looks easy for everyone else.  You Keep going. One step at a time.
                    
                    ASK FOR HELP.  Kage has learned that the secret of leaders, senseis is that they learned to ask for help, ask for how, and keep asking until they have comprehension.  Learn from teachers, tutors, mentors.                    
                    
                    """)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("About KageGuide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
