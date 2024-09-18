//
//
//
//
//
//
//
//
//
//
//
//
//
//
//// WelcomeView.swift
//import SwiftUI
//
//struct WelcomeView: View {
//    @Binding var courses: [Course]  // Example, if parameters are needed
//    var viewModel: CoursesViewModel  // Example, if parameters are needed
//
//    var body: some View {
//        VStack {
//            // Content of the Welcome View
//        }
//    }
//}
//
//struct WelcomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        WelcomeView(courses: .constant([]), viewModel: CoursesViewModel())  // Ensure parameters are provided
//    }
//}
//
//////  BELOW IS OLD CODE
/////
//////  WelcomeView.swift
//////  ADHDCoach
//////
//////  Created by Ethan Becker on 8/23/24.
//////
////
////import SwiftUI
////
////struct WelcomeView: View {
////    @Binding var courses: [Course]
////    @EnvironmentObject var appSettings: AppSettings
////    @EnvironmentObject var calendarManager: CalendarManager
////    var viewModel: CoursesViewModel
////
////    var body: some View {
////        NavigationView {
////            ZStack {
////                // Background Image
////                Image("ninja-background")
////                    .resizable()
////                    .aspectRatio(contentMode: .fill)
////                    .edgesIgnoringSafeArea(.all)
////                    .opacity(0.3)
////
////                VStack(spacing: 20) {
////                    // App Name
////                    Text("KageGuide")
////                        .font(.largeTitle)
////                        .fontWeight(.bold)
////                        .multilineTextAlignment(.center)
////                        .foregroundColor(.green)
////                        .padding(.top, 60)
////
////                    // App Description
////                    Text("Your personal guide to mastering focus and conquering tasks.")
////                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
////                        .font(.title3)
////                        .foregroundColor(.black)
////                        .multilineTextAlignment(.center)
////                        .padding(.horizontal)  // Use default horizontal padding
////                        
////                    // About Button
////                    NavigationLink(destination: AboutView()) {
////                        Text("About KageGuide")
////                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
////                            .padding()
////                            .frame(height: 30)
////                            .background(Color.teal)
////                            .foregroundColor(.white)
////                            .cornerRadius(10)
////                    }
////
////                    Spacer()
////                    
////                    // School Name or Settings
////                    if !appSettings.schoolName.isEmpty {
////                        Text("School: \(appSettings.schoolName)")
////                            .font(.headline)
////                            .foregroundColor(.green)
////                            .padding(.horizontal, 20)
////                    } else {
////                        NavigationLink(destination: SettingsView()) {
////                            Text("Set School Name")
////                                .frame(maxWidth: UIScreen.main.bounds.width * 0.8)  // 80% of the screen width
////                                .padding()
////                                .frame(height: 30)
////                                .background(Color.black)
////                                .foregroundColor(.white)
////                                .cornerRadius(10)
////                        }
////                    }
////
////                    Spacer()
////
////                    // Courses Button
////                    NavigationLink(destination: CoursesView(courses: $courses, viewModel: viewModel)) {
////                        Text("Courses")
////                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
////                            .padding()
////                            .frame(height: 30)
////                            .background(Color.indigo)
////                            .foregroundColor(.white)
////                            .cornerRadius(10)
////                    }
////
////                    // Master Summary Button
////                    NavigationLink(destination: MasterSummaryView(courses: courses)) {
////                        Text("Master Summary")
////                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
////                            .padding()
////                            .frame(height: 30)
////                            .background(Color.indigo)
////                            .foregroundColor(.white)
////                            .cornerRadius(10)
////                    }
////
////                  
////                    Spacer()
////                }
////                .padding()
////                .frame(maxWidth: .infinity)
////            }
////            .navigationTitle("")
////            .navigationBarHidden(true)
////        }
////    }
////}
////
////struct WelcomeView_Previews: PreviewProvider {
////    static var previews: some View {
////        WelcomeView(courses: .constant([]), viewModel: CoursesViewModel())
////            .environmentObject(AppSettings())
////            .environmentObject(CalendarManager())
////    }
////}
