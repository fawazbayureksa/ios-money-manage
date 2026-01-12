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
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Basic validation
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            // Demo logic
            if self.email.isEmpty || self.password.isEmpty {
                self.errorMessage = "Please fill in all fields"
            } else {
                print("Login with \(self.email)")
            }
        }
    }
}
