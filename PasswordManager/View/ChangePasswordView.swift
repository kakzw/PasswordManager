//
//  ChangePasswordView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/16/24.
//

import SwiftUI

struct ChangePasswordView: View {
  @Environment(\.dismiss) var dismiss

  private var pwManager = PasswordManager.shared
  @State private var curPw = ""
  @State private var newPw = ""
  @State private var wrongPw = false

  var body: some View {
    VStack {
      TextFieldView(title: "Current Password", showFooter: false, text: $curPw)
      TextFieldView(title: "New Password", showFooter: true, text: $newPw)

      Text("Wrong Password")
        .bold()
        .foregroundStyle(Color.red)
        .opacity(wrongPw ? 1 : 0)

      Spacer()
    }
    .padding()
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
			
      ToolbarItem(placement: .topBarTrailing) {
        Button {
					// if current password is correct
					// set new password and go back to ContentView
          if pwManager.doesMasterPasswordMatch(curPw) {
            pwManager.setMasterPassword(newPw)
            dismiss()
          } else {
            wrongPw = true
          }
        } label: {
          Label("Save", systemImage: "save")
        }
        .disabled(curPw.isEmpty || newPw.isEmpty)
      }
    }
    .toolbarBackground(.orange, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .navigationBarBackButtonHidden()
  }
}

//#Preview {
//    ChangePasswordView()
//}
