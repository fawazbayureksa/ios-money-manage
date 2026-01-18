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
    
    // Callback for success
    var onLoginSuccess: (() -> Void)?
    
    // Basic validation
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    struct LoginRequest: Encodable {
        let email: String
        let message: String // API seems to expect 'message' for password based on typical dummy APIs, but for 'money-manage' usually it's 'password'. I'll stick to 'password' as per standard, or if user code implies otherwise. Wait, Standard is email/password.
        // Let's check if I should use 'password' or something else. I'll use 'password'.
        let password: String
    }
    
    struct User: Decodable {
        let id: Int
        let name: String
        let email: String
    }
    
    struct LoginData: Decodable {
        let token: String
        let user: User
    }
    
    struct LoginResponse: Decodable {
        let success: Bool
        let message: String?
        let data: LoginData?
    }
    
    func login() {
        guard isValid else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("API_BASE_URL =", AppConfig.apiBaseURL)
        
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/login") else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        print(body)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request"
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid server response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Login failed: \(httpResponse.statusCode)"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data!)
                    
                    if decoded.success {
                        print("✅ Login success")
                        if let loginData = decoded.data {
                            if let token = decoded.data?.token {
                                TokenManager.shared.saveToken(token)
                            }
                        }
                         self?.onLoginSuccess?()
                    } else {
                        self?.errorMessage = decoded.message ?? "Login failed"
                    }
                } catch {
                    print("❌ Decode error:", error)
                    self?.errorMessage = "Failed to parse response"
                }

            }
        }.resume()
    }
}
