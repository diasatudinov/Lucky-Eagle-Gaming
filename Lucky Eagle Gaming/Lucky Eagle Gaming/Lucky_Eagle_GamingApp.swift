//
//  Lucky_Eagle_GamingApp.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

@main
struct Lucky_Eagle_GamingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LEGRoot()
                .preferredColorScheme(.light)
        }
    }
}
