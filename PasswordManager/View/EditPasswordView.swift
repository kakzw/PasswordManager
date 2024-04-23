//
//  EditPasswordView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/16/24.
//

import SwiftUI

struct EditPasswordView: View {
  @Environment(\.managedObjectContext) var managedObjContext
  @Environment(\.dismiss) var dismiss

  var pwManager = PasswordManager.shared
  var pw: FetchedResults<Passwords>.Element
  @State private var title = ""
  @State private var username = ""
  @State private var password = ""
	@State private var note = ""
	@State private var website = ""
	@State private var strongPassword = ""
	@State private var showCopy = false
	@State private var pwStrength = 0
  @State private var showAlert = false

  var body: some View {
		ZStack {
			VStack {
				TextFieldView(title: "Title", 
                      showFooter: true,
                      text: $title)
				Divider()
				TextFieldView(title: "Username", 
                      showFooter: true,
                      text: $username)
				Divider()
				TextFieldView(title: "Password", 
                      showFooter: true,
                      text: $password)
        .alert("Are you sure?", isPresented: $showAlert) {
          Button("Cancel", role: .cancel) { }
          Button("Save") {
            savePassword()
          }
        } message: {
          Text("Password is weak and can be easily guessed.")
        }
        PwStrengthView(pwStrength: $pwStrength)
				StrongPasswordView(strongPassword: $strongPassword,
                           pw: $password,
                           showCopy: $showCopy)
				Divider()
				
				Section {
					HStack {
						Text("Note")
							.font(.subheadline)
							.bold()
							.opacity(0.5)
							.frame(maxWidth: .infinity, alignment: .leading)
							.offset(x: 10)
						Spacer()
					}
				}
				TextField("Add Note", text: $note, axis: .vertical)
					.lineLimit(2...)
					.autocapitalization(.none)
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(10)
        Divider()
				TextFieldView(title: "Website",
											showFooter: false,
											text: $website)

				Spacer()
			}
			
			// popup view to let the user know that strong password is copied
			VStack {
				Spacer()
				Text("Text Copied")
					.padding()
					.frame(width: 280, alignment: .center)
					.foregroundStyle(Color.white)
					.background(Color(.orange))
					.cornerRadius(12)
			}
			.opacity(showCopy ? 1 : 0)
		}
    .padding()
    .navigationTitle("Edit Password")
		.onChange(of: password, { _, _ in
			pwStrength = pwManager.getPasswordStrength(password)
		})
    .onAppear {
      title = pw.title!
      username = pw.username!
      password = pwManager.getPassword(pw.password!)
			note = pw.note!
			website = pw.website!
			strongPassword = pwManager.generatePassword()
    }
    .toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					HStack {
						Image(systemName: "chevron.left")
						Text("Back")
					}
				}
			}
			
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          if pwStrength < 4 {
            showAlert = true
          } else {
            savePassword()
          }
        } label: {
          Text("Save")
        }
        .disabled(title.isEmpty || username.isEmpty || password.isEmpty)
      }
    }
    .toolbarBackground(.orange, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .navigationBarBackButtonHidden()
  }

  private func savePassword() {
    pwManager.editPassword(Password(title: title,
                                    username: username,
                                    password: password,
                                    note: note,
                                    website: website),
                           to: pw, context: managedObjContext)
    dismiss()
  }
}

//#Preview {
//	EditPasswordView()
//}
