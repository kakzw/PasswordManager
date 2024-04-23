//
//  PasswordListView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI

struct PasswordListView: View {
  @Environment(\.managedObjectContext) var managedObjContext
  @Environment(\.dismiss) var dismiss
  @FetchRequest(sortDescriptors: [SortDescriptor(\Passwords.title)]) var pw: FetchedResults<Passwords>

  private var pwManager = PasswordManager.shared
  @State private var username = ""
  @State private var showAddView = false
  @State private var showAlert = false
  @State private var pwToDelete = [Passwords]()

  var body: some View {
    VStack {
      if pw.isEmpty {
        Text("There are no passwords saved.")
          .padding()
          .bold()
          .opacity(0.7)
        Spacer()
      } else {
        List {
          // display each pw's title and username
          // if tapped, navigate to detail view of that pw
          ForEach(pw) { pw in
            NavigationLink(destination: PasswordDetailView(pw: pw)) {
              VStack {
                Text(pw.title!)
                  .font(.subheadline)
                  .bold()
                  .opacity(0.8)
                  .frame(maxWidth: .infinity, alignment: .leading)

                Text(pw.username!)
                  .font(.footnote)
                  .opacity(0.5)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
          }
          .onDelete(perform: showAlert)
        }
        // show alert message before deleting password
        .alert("Are you sure?", isPresented: $showAlert) {
          Button("Cancel", role: .cancel) { }
          Button("Delete", role: .destructive) {
            // delete @pwToDelete from database
            // when user attempts to delete, pwToDelete is set to that pw
            for pw in pwToDelete {
              DataController().deletePassword(pw, context: managedObjContext)
            }
          }
        } message: {
          Text("Are you sure you want to delete the password?")
        }
      }
    }
    .navigationDestination(isPresented: $showAddView, destination: {
      AddPasswordView()
    })
    .navigationTitle("Password List")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showAddView.toggle()
        } label: {
          Label("Add", systemImage: "plus.circle")
        }
      }
    }
    .toolbarBackground(.orange, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .navigationBarBackButtonHidden()
  }

  // sets @pwToDelete to pw that user attempted to delete
  // and shows alert
  private func showAlert(offsets: IndexSet) {
    pwToDelete = offsets.map{ pw[$0] }
    showAlert = true
  }
}


//#Preview {
//  PasswordListView()
//}
