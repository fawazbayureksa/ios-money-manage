//
//  RootView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject var authState: AuthState

    var body: some View {
        if authState.isLoggedIn {
            ContentView()
        } else {
            LoginView()
        }
    }
}
