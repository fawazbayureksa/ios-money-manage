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

    init() {
        checkLogin()
    }

    func checkLogin() {
        // Check if token exists
        if let token = TokenManager.shared.getToken(), !token.isEmpty {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }

    func loginSuccess() {
        isLoggedIn = true
    }

    func logoutSuccess() {
        isLoggedIn = false
    }
}
