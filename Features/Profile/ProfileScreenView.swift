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
    @StateObject private var alertViewModel = BudgetAlertViewModel()
    @State private var showBudgetAlerts = false
    @State private var showWallets = false
    @State private var showCategoryManagement = false
    @State private var budgetAlertCount = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.gray.opacity(0.1))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        ProfileHeaderView(username: authState.user?.name ?? "User")
                            .padding(.top, 8)
                        
                        // Menu Items
                        VStack(spacing: 16) {
                            // Budget Alert Section
                            MenuSectionView(title: "Financial Management") {
                                MenuItemView(
                                    icon: "bell.badge",
                                    title: "Budget Alerts",
                                    description: "View and manage budget notifications",
                                    badgeCount: budgetAlertCount,
                                    color: Color(.orange),
                                    action: {
                                        showBudgetAlerts = true
                                    }
                                )
                                
                                MenuItemView(
                                    icon: "folder.badge.gearshape",
                                    title: "Manage Categories",
                                    description: "Create and manage expense/income categories",
                                    badgeCount: nil,
                                    color: .cyan,
                                    action: {
                                        showCategoryManagement = true
                                    }
                                )
                                
                                MenuItemView(
                                    icon: "wallet.bifold",
                                    title: "Wallet & Assets",
                                    description: "Manage your accounts and assets",
                                    badgeCount: nil,
                                    color: .purple,
                                    action: { 
                                        showWallets = true
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
                            
                            // Logout Button (Standalone)
                            LogoutButtonView(logoutModel: logoutModel) {
                                authState.logoutSuccess()
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40) // Extra padding for bottom-most item
                        
                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showBudgetAlerts) {
                BudgetAlertScreenView(
                    viewModel: alertViewModel,
                    onUnreadCountChanged: { newCount in
                        budgetAlertCount = newCount
                    }
                )
            }
            .navigationDestination(isPresented: $showCategoryManagement) {
                CategoryManagementScreenView()
            }
            .navigationDestination(isPresented: $showWallets) {
                WalletScreenView()
            }
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
            .task {
                await fetchUnreadAlertCount()
            }
            .refreshable {
                await fetchUnreadAlertCount()
            }
        }
    }
    
    // MARK: - Fetch Unread Alert Count
    
    private func fetchUnreadAlertCount() async {
        do {
            budgetAlertCount = try await AlertService.shared.getUnreadCount()
        } catch {
            budgetAlertCount = 0
        }
    }
}

// MARK: - Profile Header View

private struct ProfileHeaderView: View {
    let username: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Avatar Column
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(.white.opacity(0.4), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                Text(String(username.prefix(2)).uppercased())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
            
            // User Info Column
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(username)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Premium Member")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.white.opacity(0.2)))
                }
                
                HStack(spacing: 16) {
                    StatItemView(title: "Joined", value: "2026")
                    // Divider()
                    //     .frame(height: 20)
                    //     .background(Color.white.opacity(0.3))
                    // StatItemView(title: "Budgets", value: "10")
                    // Divider()
                    //     .frame(height: 20)
                    //     .background(Color.white.opacity(0.3))
                    // StatItemView(title: "Saved", value: "24%")
                }
            }
            
            Spacer()
        }
        .padding(24)
        .background(
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.42, blue: 0.47), // Matching Home Header
                        Color(red: 0.08, green: 0.32, blue: 0.36)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Decorative Elements
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                            .offset(x: geo.size.width * 0.8, y: -20)
                        
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .blur(radius: 15)
                            .offset(x: 20, y: geo.size.height * 0.7)
                    }
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(red: 0.12, green: 0.42, blue: 0.47).opacity(0.3), radius: 12, x: 0, y: 8)
        .padding(.horizontal, 16)
    }
}

private struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
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
                    .fill(Color(UIColor.secondarySystemBackground))
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
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "power.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                }
                
                Text("Sign Out")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(0.5)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .opacity(0.5)
            }
            .foregroundColor(.red)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .disabled(logoutModel.isLoading)
        .onAppear {
            logoutModel.onLogoutSuccess = onLogoutSuccess
        }
    }
}

#Preview{
    ProfileScreenView().environmentObject(AuthState())
}
