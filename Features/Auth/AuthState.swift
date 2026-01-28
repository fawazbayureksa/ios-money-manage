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

    private let userDefaultsKey = "user_data"

    init() {
        checkLogin()
    }

    func checkLogin() {
        if let token = TokenManager.shared.getToken(), !token.isEmpty {
            isLoggedIn = true
            loadUser()
        } else {
            isLoggedIn = false
            user = nil
        }
    }

    func loginSuccess(user: LoginViewModel.User) {
        isLoggedIn = true
        self.user = user
        saveUser(user)
    }

    func logoutSuccess() {
        isLoggedIn = false
        user = nil
        clearUser()
    }

    private func saveUser(_ user: LoginViewModel.User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(LoginViewModel.User.self, from: data) {
            user = decoded
        }
    }

    private func clearUser() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
