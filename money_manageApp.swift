//
//  money_manageApp.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 10/01/26.
//

import SwiftUI

@main
struct money_manageApp: App {
    
    @StateObject private var authState = AuthState()
    var body: some Scene {
        WindowGroup {
//            ContentView()
            RootView().environmentObject(authState)
        }
    }
}
