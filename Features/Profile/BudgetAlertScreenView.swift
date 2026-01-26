//
//  BudgetAlertScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI
import Combine
import Foundation

struct BudgetAlertScreenView: View {
    @StateObject private var viewModel: BudgetAlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Optional initializer for when viewModel is passed from ProfileScreenView
    init(viewModel: BudgetAlertViewModel? = nil) {
        if let viewModel = viewModel {
            self._viewModel = StateObject(wrappedValue: viewModel)
        } else {
            self._viewModel = StateObject(wrappedValue: BudgetAlertViewModel())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.alerts.isEmpty {
                    LoadingView()
                } else {
                    VStack(spacing: 0) {
                        // Filter Section
                        FilterSection(
                            filterType: $viewModel.filterType,
                            totalItems: viewModel.totalItems,
                            hasUnreadAlerts: viewModel.hasUnreadAlerts,
                            onFilterChanged: { _ in
                                Task { await viewModel.refresh() }
                            },
                            onMarkAllRead: {
                                Task { await viewModel.markAllAsRead() }
                            }
                        )
                        .background(Color(.systemBackground))
                        
                        // Alert List
                        if viewModel.alerts.isEmpty {
                            EmptyStateView(filterType: viewModel.filterType)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.alerts) { alert in
                                        AlertCard(alert: alert) {
                                            Task {
                                                await viewModel.markAsRead(alertId: alert.id)
                                            }
                                        }
                                    }
                                    
                                    // Load More Indicator
                                    if viewModel.isLoadingMore {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                            Text("Loading more...")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 24)
                            }
                            .refreshable {
                                await viewModel.refresh()
                            }
                            
                            // Load more trigger
                            Color.clear
                                .frame(height: 0)
                                .onAppear {
                                    if viewModel.canLoadMore && !viewModel.isLoadingMore {
                                        Task {
                                            await viewModel.loadMore()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Budget Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                    viewModel.hasError = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.showSnackbar {
                SnackbarView(message: viewModel.snackbarMessage ?? "") {
                    viewModel.hideSnackbar()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            // Only load mock data if viewModel is empty and wasn't pre-loaded from ProfileScreenView
            if viewModel.alerts.isEmpty {
                Task {
                    // Use mock data for now, replace with API call when ready
                    // await viewModel.fetchAlerts()
                    viewModel.loadMockData()
                }
            }
        }
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading alerts...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Filter Section

private struct FilterSection: View {
    @Binding var filterType: AlertFilterType
    let totalItems: Int
    let hasUnreadAlerts: Bool
    let onFilterChanged: (AlertFilterType) -> Void
    let onMarkAllRead: () -> Void
    
    var body: some View {
        HStack {
            // Filter Chips
            HStack(spacing: 8) {
                BudgetFilterChip(
                    title: "All \(totalItems > 0 ? "(\(totalItems))" : "")",
                    isSelected: filterType == .all,
                    color: .blue
                ) {
                    filterType = .all
                    onFilterChanged(.all)
                }
                
                BudgetFilterChip(
                    title: "Unread",
                    isSelected: filterType == .unread,
                    color: .orange
                ) {
                    filterType = .unread
                    onFilterChanged(.unread)
                }
            }
            
            Spacer()
            
            // Mark All Read Button
            if hasUnreadAlerts {
                Button(action: onMarkAllRead) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                        Text("Mark All")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct BudgetFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    let filterType: AlertFilterType
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(filterType == .unread ? "No Unread Alerts" : "No Alerts Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(filterType == .unread ? "You're all caught up!" : "You'll be notified when you approach your budget limits")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Alert Card

private struct AlertCard: View {
    let alert: BudgetAlert
    let onMarkAsRead: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Alert Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(alert.alertColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: alert.alertIconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(alert.alertColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // Title Row
                    HStack {
                        Text(alert.categoryName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if !alert.isRead {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    // Message
                    Text(alert.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Amounts Row
                    AmountsRow(alert: alert)
                }
            }
            .padding(20)
            
            // Footer
            HStack {
                Text(alert.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !alert.isRead {
                    Button(action: onMarkAsRead) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                            Text("Mark Read")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    !alert.isRead ? alert.alertColor.opacity(0.3) : Color.clear,
                    lineWidth: !alert.isRead ? 4 : 0
                ),
            alignment: .leading
        )
    }
}

private struct AmountsRow: View {
    let alert: BudgetAlert
    
    var body: some View {
        HStack(spacing: 0) {
            AmountItem(label: "Spent", value: alert.formattedSpentAmount, color: alert.alertColor)
            Divider()
                .frame(height: 20)
            AmountItem(label: "Budget", value: alert.formattedBudgetAmount, color: .primary)
            Divider()
                .frame(height: 20)
            AmountItem(label: "Usage", value: "\(Int(alert.percentage))%", color: alert.alertColor)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private struct AmountItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Snackbar View

private struct SnackbarView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button("Dismiss") {
                onDismiss()
            }
            .font(.subheadline)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview("With Alerts") {
    BudgetAlertScreenView()
        .environmentObject(AuthState())
}

#Preview("Empty State") {
    BudgetAlertScreenView()
        .environmentObject(AuthState())
        .onAppear {
            // Will show empty state initially
        }
}
