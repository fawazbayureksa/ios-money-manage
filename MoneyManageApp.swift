//
//  money_manageApp.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 10/01/26.
//

import SwiftUI


@main
struct MoneyManageApp: App {
    
    @StateObject private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
//            ContentView()
            RootView()
                .environmentObject(authState)
                .onOpenURL { url in
                    handleEmailSyncCallback(url)
                }
        }
    }

    private func handleEmailSyncCallback(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        let result = components.queryItems?
            .first(where: { $0.name == "email_sync" })?
            .value

        let isEmailSyncCallback = url.host == "email-sync" || url.path.contains("email-sync")
        if isEmailSyncCallback && result == "success" {
            NotificationCenter.default.post(name: .emailSyncConnected, object: nil)
        }
    }
}


