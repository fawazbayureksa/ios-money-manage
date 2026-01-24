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
    @State private var budgetAlertCount = 3 // Mock data for unread alerts
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.gray.opacity(0.1))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        ProfileHeaderView(username: "User")
                        
                        // Menu Items
                        VStack(spacing: 16) {
                            // Budget Alert Section
                            MenuSectionView(title: "Financial Management") {
                                MenuItemView(
                                    icon: "bell.badge",
                                    title: "Budget Alerts",
                                    description: "View and manage budget notifications",
                                    badgeCount: budgetAlertCount,
                                    color: .orange,
                                    action: { 
                                        print("Budget Alerts tapped")
                                    }
                                )
                                
                                MenuItemView(
                                    icon: "wallet.bifold",
                                    title: "Wallet & Assets",
                                    description: "Manage your accounts and assets",
                                    badgeCount: nil,
                                    color: .purple,
                                    action: { 
                                        print("Wallet & Assets tapped")
                                    }
                                )
                            }
                            
                            // Account Section
                            MenuSectionView(title: "Account") {
                                MenuItemView(
                                    icon: "person.circle",
                                    title: "Personal Information",
                                    description: "Update your profile details",
                                    badgeCount: nil,
                                    color: .blue,
                                    action: { 
                                        print("Personal Information tapped")
                                    }
                                )
                                
                                MenuItemView(
                                    icon: "gear",
                                    title: "Settings",
                                    description: "App preferences and configurations",
                                    badgeCount: nil,
                                    color: .gray,
                                    action: { 
                                        print("Settings tapped")
                                    }
                                )
                                
                                MenuItemView(
                                    icon: "questionmark.circle",
                                    title: "Help & Support",
                                    description: "Get help and contact support",
                                    badgeCount: nil,
                                    color: .green,
                                    action: { 
                                        print("Help & Support tapped")
                                    }
                                )
                            }
                            
                            // Logout Section
                            MenuSectionView(title: "") {
                                LogoutButtonView(logoutModel: logoutModel) {
                                    authState.logoutSuccess()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $logoutModel.showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    logoutModel.onLogoutSuccess = { () -> Void in
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

// MARK: - Profile Header View

private struct ProfileHeaderView: View {
    let username: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)
                
                Text(String(username.prefix(2)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
            
            // User Info
            VStack(spacing: 8) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Premium Member")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    StatItemView(title: "Joined", value: "2024")
                    StatItemView(title: "Budgets", value: "12")
                    StatItemView(title: "Saved", value: "24%")
                }
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

private struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Menu Section View

private struct MenuSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Menu Item View

private struct MenuItemView: View {
    let icon: String
    let title: String
    let description: String
    let badgeCount: Int?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Badge or Arrow
                HStack(spacing: 8) {
                    if let badgeCount = badgeCount, badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(color)
                            )
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Logout Button View

private struct LogoutButtonView: View {
    @ObservedObject var logoutModel: LogoutModel
    let onLogoutSuccess: () -> Void
    
    var body: some View {
        Button {
            logoutModel.confirmLogout()
        } label: {
            HStack(spacing: 12) {
                if logoutModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "power")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text("Sign Out")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.6)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .disabled(logoutModel.isLoading)
        .onAppear {
            logoutModel.onLogoutSuccess = onLogoutSuccess
        }
    }
}
