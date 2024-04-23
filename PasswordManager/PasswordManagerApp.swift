//
//  PasswordManagerApp.swift
//  PasswordManager
//
//  Created by Kento Akazawa on 4/15/24.
//

import SwiftUI

@main
struct PasswordManagerApp: App {
  @StateObject private var dataController = DataController()

	var body: some Scene {
		WindowGroup {
			ContentView()
        .environment(\.managedObjectContext, dataController.container.viewContext)
		}
	}
}
