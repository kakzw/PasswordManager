//
//  AddPasswordView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI

struct AddPasswordView: View {
  @Environment(\.managedObjectContext) var managedObjContext
  @Environment(\.dismiss) var dismiss

  private var pwManager = PasswordManager.shared
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
      .opacity(showCopy ? 0.7 : 1)

      PopupView(text: "Text Copied", show: $showCopy)
    }
    .navigationTitle("Add Password")
    .onChange(of: password, { _, _ in
      pwStrength = pwManager.getPasswordStrength(password)
    })
    .onAppear {
      strongPassword = pwManager.generatePassword()
    }
    .toolbar {
      // back button to go back to previous screen
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

      // saves new password
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
    .padding()
    .toolbarBackground(.orange, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .navigationBarBackButtonHidden()
  }

  private func savePassword() {
    pwManager.addPassword(Password(title: title,
                                   username: username,
                                   password: password,
                                   note: note,
                                   website: website),
                          context: managedObjContext)
    dismiss()
  }
}

struct TextFieldView: View {
  var title: String
  var showFooter: Bool
  @Binding var text: String

  var body: some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .bold()
        .opacity(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x: 10)
      Spacer()
    }

    TextField("", text: $text)
      .autocapitalization(.none)
      .padding()
      .opacity(0.7)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color(.systemGray6))
      .cornerRadius(10)
      .overlay {
        HStack {
          Spacer()
          // deletes @text
          Image(systemName: "xmark.circle.fill")
            .padding()
            .foregroundColor(Color.secondary)
            .opacity(text.isEmpty ? 0.2 : 1)
            .onTapGesture {
              text = ""
            }
        }
      }
      .autocorrectionDisabled()
  }
}

struct StrongPasswordView: View {
  @Binding var strongPassword: String
  @Binding var pw: String
  @Binding var showCopy: Bool

  var body: some View {
    HStack {
      Text("Strong Password")
        .font(.subheadline)
        .bold()
        .opacity(0.5)
        .offset(x: 10)

      // regenerates strong password
      Button {
        strongPassword = PasswordManager.shared.generatePassword()
      } label: {
        Image(systemName: "arrow.triangle.2.circlepath")
          .foregroundStyle(Color.black)
          .bold()
          .opacity(0.4)
      }
      .padding(.horizontal)

      Spacer()
    }
    Text(strongPassword)
      .frame(maxWidth: .infinity, alignment: .leading)
      .offset(x: 10)
      // copies the strong password on long press
      .onLongPressGesture {
        showCopy = true
        UIPasteboard.general.string = strongPassword
      }
      .onChange(of: showCopy, { _, newVal in
        if newVal {
          // set the password to be strong password
          pw = strongPassword
          // show copy popup view for a second
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showCopy = false
          }
        }
      })
  }
}

// display linear progress view based on @pwStrength
struct PwStrengthView: View {
  @Binding var pwStrength: Int

  var body: some View {
    ProgressView(value: Double(pwStrength), total: 5.0)
      .scaleEffect(x: 1.0, y: 2.5)
      // change color based on strength
      .tint(getColor(pwStrength: pwStrength))
      .cornerRadius(0.2)
  }

  // if weak, red and if strong, green
  private func getColor(pwStrength: Int) -> Color{
    switch pwStrength {
    case 1:
      return Color.red
    case 2:
      return Color.init(red: 1, green: 0.5, blue: 0)
    case 3:
      return Color.yellow
    case 4:
      return Color.init(red: 0.5, green: 1, blue: 0.5)
    case 5:
      return Color.green
    default:
      return Color.white
    }
  }
}

//#Preview {
//  AddPasswordView()
//}
