//
//  ProfileScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//
import SwiftUI

struct ProfileScreenView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var logoutModel = LogoutModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Logout Button
                Button {
                    logoutModel.confirmLogout()
                } label: {
                    HStack(spacing: 12) {
                        if logoutModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "power")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(logoutModel.isLoading)
            }
            .padding(16)
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $logoutModel.showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    logoutModel.onLogoutSuccess = {
                        authState.logoutSuccess()
                    }
                    logoutModel.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}
