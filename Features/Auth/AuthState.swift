//
//  AuthState.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthState: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var user: LoginViewModel.User? = nil

    init() {
        checkLogin()
    }

    func checkLogin() {
        // Check if token exists
        if let token = TokenManager.shared.getToken(), !token.isEmpty {
            isLoggedIn = true
            // TODO: Fetch user info from API or local storage if needed
        } else {
            isLoggedIn = false
            user = nil
        }
    }

    func loginSuccess(user: LoginViewModel.User) {
        isLoggedIn = true
        self.user = user
    }

    func logoutSuccess() {
        isLoggedIn = false
        user = nil
    }
}
