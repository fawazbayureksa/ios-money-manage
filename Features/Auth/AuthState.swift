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
        // TEMP: first load always go to login
        // later replace with token check
        isLoggedIn = false
    }

    func loginSuccess() {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }
}
