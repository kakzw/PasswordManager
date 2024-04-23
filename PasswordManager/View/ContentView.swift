//
//  ContentView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
  @Environment(\.managedObjectContext) var managedObjContext

  private var pwManager = PasswordManager.shared
  @State var accessGranted = false
  @State var showChangeView = false

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()

        Image(systemName: "lock")
          .resizable()
          .frame(width: 150, height: 200)
          .foregroundColor(.secondary)

        Text("Password Locked")
          .font(.headline)
          .opacity(0.5)
          .bold()

        Spacer()
          .frame(height: 10)

        MasterPasswordView(accessGranted: $accessGranted, showChangeView: $showChangeView)

        Spacer()
      }
      .navigationDestination(isPresented: $accessGranted, destination: {
        PasswordListView()
      })
      .navigationDestination(isPresented: $showChangeView, destination: {
        ChangePasswordView()
      })
      .padding()
      .navigationTitle("Password")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.orange, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
			// make foreground color of title to white
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }
}

struct MasterPasswordView: View {
  @Binding var accessGranted: Bool
  @Binding var showChangeView: Bool

  var pwManager = PasswordManager.shared
  @State var masterPassword = ""
  @State var pwEntered = false

  var body: some View {
		// if master password has not been set
		// display text, "Set Password"
    if !pwManager.doesMasterPasswordExist() {
      Text("Set Password")
        .font(.subheadline)
        .bold()
        .opacity(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x: 10)
    }
    Section {
      TextField("Password", text: $masterPassword)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay {
					// button to delete entered text
          HStack {
            Spacer()
            Image(systemName: "xmark.circle.fill")
              .padding()
              .foregroundColor(Color.secondary)
              .onTapGesture {
                masterPassword = ""
              }
          }
          .opacity(masterPassword.isEmpty ? 0.0 : 1.0)
        }
        .onChange(of: masterPassword, { _, newVal in
          // when user deletes the wrong password previously entered
          // reset @passwordEntered
          // so that it doesn't give error message
          // while retyping the password
          if newVal.isEmpty {
            pwEntered = false
          }
        })
        .onSubmit {
					// if master password has been set
					// check if it matches saved password
					// otherwise set entered text as master password
          if pwManager.doesMasterPasswordExist() {
            accessGranted = pwManager.doesMasterPasswordMatch(masterPassword)
            if !accessGranted {
              pwEntered = true
            }
          } else {
            pwManager.setMasterPassword(masterPassword)
            accessGranted = true
          }
        }
    } footer: {
      Text("You entered wrong password")
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x: 10)
        .opacity(!masterPassword.isEmpty && pwEntered ? 1 : 0)
    }
		// if master password has been set
		// allow user to change password
    if pwManager.doesMasterPasswordExist() {
      Button {
        showChangeView = true
      } label: {
        Text("Change Password")
          .foregroundStyle(Color.blue)
          .underline()
      }
    }
  }
}

//#Preview {
//  ContentView()
//}
