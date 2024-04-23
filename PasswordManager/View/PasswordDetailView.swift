//
//  EditPasswordView.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI
import WebKit

struct PasswordDetailView: View {
  @Environment(\.managedObjectContext) var managedObjContext
  @Environment(\.dismiss) var dismiss

  var pwManager = PasswordManager.shared
  var pw: FetchedResults<Passwords>.Element
  @State private var hidePassword = true
  @State private var showEditView = false
  @State private var showCopy = false
  @State private var showAlert = false
  @State private var showUrlInvalid = false

  var body: some View {
    ZStack {
      if pw.id != nil {
        VStack {
          TextView(title: "Username",
                   text: pw.username!,
                   isNote: false, 
                   showCopy: $showCopy)

          // display password as "●" initially
          if hidePassword {
            TextView(title: "Password",
                     text: String(repeating: "●",
                                  count: pwManager.getPassword(pw.password!).count),
                     isNote: false, 
                     showCopy: $showCopy)
            .onTapGesture {
              hidePassword = false
            }
          } else {
            TextView(title: "Password",
                     text: pwManager.getPassword(pw.password!),
                     isNote: false, 
                     showCopy: $showCopy)
            .onTapGesture {
              hidePassword = true
            }
          }

          TextView(title: "Note",
                   text: pw.note!,
                   isNote: true, 
                   showCopy: $showCopy)

          WebTextView(website: pw.website!,
                      showCopy: $showCopy,
                      showUrlInvalid: $showUrlInvalid)

          Spacer()

          // delete button
          Button {
            // shows alert before deleting
            showAlert = true
          } label: {
            Text("Delete Password")
              .opacity(0.7)
              .frame(width: 280, height: 50, alignment: .center)
              .foregroundStyle(Color.red)
              .background(Color(.systemGray6))
              .cornerRadius(10)
              .alert("Are you sure?", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) { }
                // delete pw from database and go back to pw list
                Button("Delete", role: .destructive) {
                  dismiss()
                  DataController().deletePassword(pw, context: managedObjContext)
                }
              } message: {
                Text("Are you sure you want to delete the password?")
              }
          }
        }
        .onChange(of: showCopy) { _, newVal in
          if newVal {
            // show copy popup view for a second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              showCopy = false
            }
          }
        }
        .onChange(of: showUrlInvalid) { _, newVal in
          if newVal {
            // show invalid url popup view for a second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              showUrlInvalid = false
            }
          }
        }
      }

      PopupView(text: "Text Copied", show: $showCopy)
      PopupView(text: "Invalid URL", show: $showUrlInvalid)
    }
    .navigationDestination(isPresented: $showEditView, destination: {
      EditPasswordView(pw: pw)
    })
    .padding()
    .navigationTitle(pw.title ?? "")
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
          showEditView = true
        } label: {
          Text("Edit")
        }
      }
    }
    .toolbarBackground(.orange, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .navigationBarBackButtonHidden()
  }
}

struct TextView: View {
  var title: String
  var text: String
  var isNote: Bool
  @Binding var showCopy: Bool

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

    Text(text)
      .padding()
      .opacity(0.7)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color(.systemGray6))
      .cornerRadius(10)
      .multilineTextAlignment(.leading)
      .overlay {
        // cannot copy pw when hidden or note
        if !text.contains("●") && !isNote {
          HStack {
            Spacer()
            // copies entered text
            Image(systemName: "doc")
              .padding()
              .opacity(0.5)
              .onTapGesture {
                showCopy = true
                UIPasteboard.general.string = text
              }
          }
        }
      }
  }
}

struct WebTextView: View {
  var website: String
  @Binding var showCopy: Bool
  @Binding var showUrlInvalid: Bool

  @State private var showWebsite = false
  @State private var addProtocol = false

  var body: some View {
    HStack {
      Text("Website")
        .font(.subheadline)
        .bold()
        .opacity(0.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x: 10)
      Spacer()
    }

    Button {
      // check if url is valid
      // if not, add "https://" and check if it is valid
      // otherwise, it's not valid url
      if let url = URL(string: website), UIApplication.shared.canOpenURL(url) {
        showWebsite = true
        print("valid url")
      } else if let url = URL(string: "https://\(website)"), UIApplication.shared.canOpenURL(url) {
        addProtocol = true
        showWebsite = true
        print("add http \(website)")
      } else {
        showUrlInvalid = true
      }
    } label: {
      Text(website)
        .padding()
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.black)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .multilineTextAlignment(.leading)
        .overlay {

          HStack {
            Spacer()
            // copies entered text
            Image(systemName: "doc")
              .padding()
              .opacity(0.5)
              .foregroundStyle(Color.black)
              .onTapGesture {
                showCopy = true
                UIPasteboard.general.string = website
              }
          }
        }
    }
    .sheet(isPresented: $showWebsite) {
      WebView(url: website, addProtocol: $addProtocol)
    }
  }
}

// text at the bottom of the screen
// display this view while @show is true
struct PopupView: View {
  var text: String
  @Binding var show: Bool

  var body: some View {
    VStack {
      Spacer()
      Text(text)
        .padding()
        .frame(width: 280, alignment: .center)
        .foregroundStyle(Color.white)
        .background(Color(.orange))
        .cornerRadius(12)
    }
    .opacity(show ? 1 : 0)
  }
}

// Webview inside the app
struct WebView: UIViewRepresentable {
  let url: String
  @Binding var addProtocol: Bool

  func makeUIView(context: Context) -> WKWebView {
    return WKWebView()
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    let urlString = addProtocol ? "https://\(url)" : url
    let request = URLRequest(url: URL(string: urlString)!)
    webView.load(request)
  }
}

//#Preview {
//  PasswordDetailView(title: "Title", username: "Username", password: "Password")
//}
