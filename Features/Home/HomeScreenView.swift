//
//  HomeScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 13/01/26.
//
import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var authState: AuthState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header
                            HeaderView(username: authState.user?.name ?? "User")
                            
                            // Dashboard Content
                            if let data = viewModel.dashboardData {
                                DashboardContent(viewModel: viewModel, data: data)
                            } else {
                                EmptyStateView()
                            }
                            
                            Spacer(minLength: 32)
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onAppear {
                // Pass the username to viewModel
                viewModel.setUsername(authState.user?.name ?? "User")
                
                Task {
                    await viewModel.fetchDashboard()
                }
            }
            .onChange(of: authState.user?.name) { _, newName in
                // Update username in viewModel when it changes in authState
                if let name = newName {
                    viewModel.setUsername(name)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading dashboard...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Dashboard Content

private struct DashboardContent: View {
    @ObservedObject var viewModel: HomeViewModel
    let data: DashboardSummary
    
    var body: some View {
        VStack(spacing: 16) {
            // Quick Stats
            QuickStatsSection(
                data: data.currentMonth,
                showAmounts: viewModel.showAmounts,
                onToggleAmountVisibility: {
                    viewModel.toggleAmountVisibility()
                }
            )
            
            // Net Savings Card
            NetSavingsCard(
                netAmount: data.currentMonth.netAmount,
                showAmounts: viewModel.showAmounts,
                activeBudgets: data.budgetSummary?.activeBudgets ?? 0
            )
            
            // Top Spending Categories
            if !data.topCategories.isEmpty {
                TopCategoriesSection(
                    categories: data.topCategories,
                    showAmounts: viewModel.showAmounts
                )
            }
            
            // Budget Overview
            if let budgetSummary = data.budgetSummary {
                BudgetOverviewSection(
                    summary: budgetSummary,
                    showAmounts: viewModel.showAmounts
                )
            }
            
            // Recent Transactions
            if !data.recentTransactions.isEmpty {
                RecentTransactionsSection(
                    transactions: data.recentTransactions,
                    showAmounts: viewModel.showAmounts
                )
            }
            
            // Quick Actions
            QuickActionsSection()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Quick Stats Section

private struct QuickStatsSection: View {
    let data: MonthSummary
    let showAmounts: Bool
    let onToggleAmountVisibility: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Stats")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onToggleAmountVisibility) {
                    Image(systemName: showAmounts ? "eye" : "eye.slash")
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 12) {
                // Income Card
                StatCard(
                    title: "Income",
                    amount: data.formattedIncome,
                    icon: "arrow.up",
                    color: .green,
                    showAmounts: showAmounts
                )
                
                // Expense Card
                StatCard(
                    title: "Expenses",
                    amount: data.formattedExpense,
                    icon: "arrow.down",
                    color: .red,
                    showAmounts: showAmounts
                )
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let amount: String
    let icon: String
    let color: Color
    let showAmounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Text(showAmounts ? amount : "••••••")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
        )
    }
}

// MARK: - Net Savings Card

private struct NetSavingsCard: View {
    let netAmount: Double
    let showAmounts: Bool
    let activeBudgets: Int
    
    private var formattedNetAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: netAmount)) ?? "Rp0"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Net Savings
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    Text("Net Savings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(showAmounts ? formattedNetAmount : "••••••")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(netAmount >= 0 ? .green : .red)
            }
            
            Spacer()
            
            // Active Budgets
            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Active Budgets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                Text("\(activeBudgets)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Top Categories Section

private struct TopCategoriesSection: View {
    let categories: [TopCategory]
    let showAmounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Spending")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Text("Categories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(categories.prefix(5).enumerated()), id: \.offset) { index, category in
                    CategoryRow(
                        category: category,
                        index: index,
                        showAmounts: showAmounts
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

private struct CategoryRow: View {
    let category: TopCategory
    let index: Int
    let showAmounts: Bool
    
    private let colors: [Color] = [
        .pink, .purple, .indigo, .cyan, .orange
    ]
    private var categoryColor: Color {
        colors[index % colors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category Name
                HStack(spacing: 10) {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 10, height: 10)
                    Text(category.categoryName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Amount
                Text(showAmounts ? category.formattedAmount : "••••••")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(categoryColor)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                        Rectangle()
                            .fill(categoryColor)
                            .frame(width: geometry.size.width * min(category.percentage, 100) / 100, height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: category.percentage)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("\(category.count) transaction\(category.count != 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", category.percentage))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(categoryColor)
                }
            }
        }
    }
}

// MARK: - Budget Overview Section

private struct BudgetOverviewSection: View {
    let summary: BudgetSummary
    let showAmounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budget Overview")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "wallet.bifold")
                    .foregroundColor(.purple)
            }
            
            // Overall Utilization
            VStack(spacing: 12) {
                HStack {
                    Text("Overall Utilization")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(String(format: "%.1f", summary.averageUtilization))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(utilizationColor)
                }
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            Rectangle()
                                .fill(utilizationColor)
                                .frame(width: geometry.size.width * min(summary.averageUtilization, 100) / 100, height: 10)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: summary.averageUtilization)
                        }
                        .frame(height: 10)
                    }
                }
                
                // Amounts
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(showAmounts ? summary.formattedTotalSpent : "••••••")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(showAmounts ? summary.formattedTotalBudgeted : "••••••")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Budget Stats
            HStack(spacing: 8) {
                BudgetStatCard(
                    count: summary.activeBudgets,
                    label: "Active",
                    color: .green
                )
                BudgetStatCard(
                    count: summary.warningBudgets,
                    label: "Warning",
                    color: .orange
                )
                BudgetStatCard(
                    count: summary.exceededBudgets,
                    label: "Exceeded",
                    color: .red
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    private var utilizationColor: Color {
        if summary.averageUtilization >= 100 { return .red }
        if summary.averageUtilization >= 80 { return .orange }
        return .green
    }
}

private struct BudgetStatCard: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
    
    private var icon: String {
        switch label {
        case "Active": return "checkmark.circle"
        case "Warning": return "exclamationmark.triangle"
        case "Exceeded": return "xmark.octagon"
        default: return "info.circle"
        }
    }
}

// MARK: - Recent Transactions Section

private struct RecentTransactionsSection: View {
    let transactions: [RecentTransaction]
    let showAmounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                ForEach(Array(transactions.prefix(5))) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        showAmounts: showAmounts
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

private struct TransactionRow: View {
    let transaction: RecentTransaction
    let showAmounts: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.isIncome ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.isIncome ? "arrow.up" : "arrow.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(transaction.isIncome ? .green : .red)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName ?? "No Category")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(transaction.description ?? transaction.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(showAmounts ? transaction.formattedAmount : "••••••")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quick Actions Section

private struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "Add Transaction",
                    description: "Record your income or expenses",
                    color: .green
                )
                
                QuickActionButton(
                    icon: "wallet.bifold.fill",
                    title: "Manage Budgets",
                    description: "Create and track spending limits",
                    color: .purple
                )
                
                QuickActionButton(
                    icon: "folder.fill",
                    title: "Categories",
                    description: "Organize your expense categories",
                    color: .blue
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("No Data Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Start by adding your first transaction")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Transaction")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeScreenView()
        .environmentObject(AuthState())
}
