//
//  ContactView.swift
//  ADHDCoach
//
//  Created by Ethan Becker on 8/24/24.
//

import SwiftUI
import MessageUI

struct ContactView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditingProfessor = false

    @State private var professorName: String = ""
    @State private var professorEmail: String = ""
    @State private var professorPhone: String = ""
    @State private var professorDiscord: String = ""
    @State private var professorX: String = ""
    @State private var professorOther: String = ""
    
    @State private var contacts: [Contact] = []
    @State private var newName: String = ""
    @State private var newEmail: String = ""
    @State private var newPhone: String = ""
    @State private var newDiscord: String = ""
    @State private var newX: String = ""
    @State private var newOther: String = ""

    @State private var selectedEmail: String?
    @State private var selectedPhone: String?
    @State private var showPhoneOptions = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: HStack {
                    Text("Professor Contact Information")
                    Spacer()
                    Button(action: { isEditingProfessor.toggle() }) {
                        Text(isEditingProfessor ? "Done" : "Edit")
                    }
                }) {
                    if isEditingProfessor {
                        TextField("Name", text: $professorName)
                        TextField("Email", text: $professorEmail)
                            .keyboardType(.emailAddress)
                        TextField("Phone Number", text: $professorPhone)
                            .keyboardType(.phonePad)
                        TextField("Discord", text: $professorDiscord)
                        TextField("X", text: $professorX)
                        TextField("Other", text: $professorOther)
                    } else {
                        VStack(alignment: .leading) {
                            Text(professorName)
                                .font(.headline)
                            
                            HStack {
                                if isValidEmail(professorEmail) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            openMail(to: professorEmail)
                                        }
                                    Text(professorEmail)
                                        .font(.subheadline)
                                        .onTapGesture {
                                            openMail(to: professorEmail)
                                        }
                                } else {
                                    Text(professorEmail)
                                        .font(.subheadline)
                                }
                            }
                            
                            HStack {
                                if isValidPhone(professorPhone) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            selectedPhone = professorPhone
                                            showPhoneOptions = true
                                        }
                                    Text(professorPhone)
                                        .font(.subheadline)
                                        .onTapGesture {
                                            selectedPhone = professorPhone
                                            showPhoneOptions = true
                                        }
                                } else {
                                    Text(professorPhone)
                                        .font(.subheadline)
                                }
                            }
                            
                            Text(professorDiscord)
                                .font(.subheadline)
                            Text(professorX)
                                .font(.subheadline)
                            Text(professorOther)
                                .font(.subheadline)
                        }
                    }
                }
                
                Section(header: Text("Other Class Related Contacts")) {
                    ForEach(contacts) { contact in
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            
                            if isValidEmail(contact.email) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            openMail(to: contact.email)
                                        }
                                    Text(contact.email)
                                        .font(.subheadline)
                                        .onTapGesture {
                                            openMail(to: contact.email)
                                        }
                                }
                            } else {
                                Text(contact.email)
                                    .font(.subheadline)
                            }
                            
                            if isValidPhone(contact.phone) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            selectedPhone = contact.phone
                                            showPhoneOptions = true
                                        }
                                    Text(contact.phone)
                                        .font(.subheadline)
                                        .onTapGesture {
                                            selectedPhone = contact.phone
                                            showPhoneOptions = true
                                        }
                                }
                            } else {
                                Text(contact.phone)
                                    .font(.subheadline)
                            }
                            
                            Text(contact.discord)
                                .font(.subheadline)
                            Text(contact.x)
                                .font(.subheadline)
                            Text(contact.other)
                                .font(.subheadline)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteContact(contact)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Name", text: $newName)
                        TextField("Email", text: $newEmail)
                            .keyboardType(.emailAddress)
                    }
                    
                    HStack {
                        TextField("Phone", text: $newPhone)
                            .keyboardType(.phonePad)
                        TextField("Discord", text: $newDiscord)
                    }
                    
                    HStack {
                        TextField("X", text: $newX)
                        TextField("Other", text: $newOther)
                        
                        Button(action: addContact) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Contact Information")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .actionSheet(isPresented: $showPhoneOptions) {
                ActionSheet(title: Text("Contact Options"), buttons: [
                    .default(Text("Call")) {
                        callPhone(number: selectedPhone ?? "")
                    },
                    .default(Text("Text")) {
                        textPhone(number: selectedPhone ?? "")
                    },
                    .cancel()
                ])
            }
        }
    }
    
    private func addContact() {
        let newContact = Contact(id: UUID(), name: newName, email: newEmail, phone: newPhone, discord: newDiscord, x: newX, other: newOther)
        contacts.append(newContact)
        newName = ""
        newEmail = ""
        newPhone = ""
        newDiscord = ""
        newX = ""
        newOther = ""
    }
    
    private func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
    }
    
    private func openMail(to email: String) {
        guard isValidEmail(email), let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func callPhone(number: String) {
        guard isValidPhone(number), let url = URL(string: "tel:\(number)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func textPhone(number: String) {
        guard isValidPhone(number), let url = URL(string: "sms:\(number)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // Simple regex check for email validity
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        // Simple check for phone number validity
        let phoneRegEx = "^[0-9+\\(\\)#\\.\\s\\/ext-]+$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
}

struct Contact: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let phone: String
    let discord: String
    let x: String
    let other: String
}
