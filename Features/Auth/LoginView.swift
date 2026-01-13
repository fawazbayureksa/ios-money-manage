//
//  LoginView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import SwiftUI
import Foundation

struct LoginView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var viewModel = LoginViewModel()
    @State private var showPassword = false
    
    // Theme Colors
    private let primaryColor = Color(red: 0.0, green: 0.5, blue: 0.5)
    private let backgroundColor = Color(uiColor: .systemGroupedBackground)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Hero Section
                VStack(spacing: 8) {
                    // Icon Container
                    ZStack {
                        Circle()
                            .fill(primaryColor)
                            .frame(width: 100, height: 100)
                            .shadow(color: primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "wallet.pass.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 24)
                    
                    Text("Welcome Back!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(primaryColor)
                    
                    Text("Sign in to manage your finances")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)
                
                // MARK: - Login Card
                VStack(spacing: 20) {
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Passwords")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            
                            if showPassword {
                                TextField("", text: $viewModel.password)
                            } else {
                                SecureField("", text: $viewModel.password)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Submit Button
                    Button(action: viewModel.login) {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.7 : 1)
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // MARK: - Footer
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button("Sign Up") {
                        // Navigate to register
                    }
                    .foregroundColor(primaryColor)
                    .fontWeight(.bold)
                }
                .padding(.bottom, 32)
                
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .onTapGesture {
            // Dismiss keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            viewModel.onLoginSuccess = {
                // Ensure UI update happens on main thread
                DispatchQueue.main.async {
                    authState.loginSuccess()
                }
            }
        }
    }
}
