//
//  LoginViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//
import Foundation
import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func login() {
        print("Login with \(email)")
    }
}
