//
//  LogoutModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LogoutModel: ObservableObject {
      
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showLogoutAlert = false
    
    var onLogoutSuccess: (() -> Void)?
    
    func logout() {
        isLoading = true
        errorMessage = nil
        
        // Clear token
        TokenManager.shared.clearToken()
        
        isLoading = false
        
        // Trigger callback to update auth state
        onLogoutSuccess?()
    }
    
    func confirmLogout() {
        showLogoutAlert = true
    }
}
