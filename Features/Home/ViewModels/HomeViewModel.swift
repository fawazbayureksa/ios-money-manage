//
//  HomeViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 23/01/26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var dashboardData: DashboardSummary?
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var showAmounts = false
    
    // User info
    var username: String {
        UserDefaults.standard.string(forKey: "username") ?? 
        UserDefaults.standard.string(forKey: "email")?.components(separatedBy: "@").first ?? "User"
    }
    
    private let token = TokenManager.shared.getToken() ?? ""
    
    func fetchDashboard(showLoader: Bool = true) async {
        guard !token.isEmpty else {
            errorMessage = "Please login to view dashboard"
            return
        }
        
        if showLoader { isLoading = true }
        errorMessage = nil
        
        do {
            dashboardData = try await fetchDashboardData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        isRefreshing = false
    }
    
    private func fetchDashboardData() async throws -> DashboardSummary {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/analytics/dashboard") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        struct Response: Decodable {
            let success: Bool
            let message: String?
            let data: DashboardSummary?
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        
        if decoded.success, let data = decoded.data {
            return data
        } else {
            throw NSError(domain: "HomeViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
        }
    }
    
    func refresh() async {
        isRefreshing = true
        await fetchDashboard(showLoader: false)
    }
    
    func toggleAmountVisibility() {
        showAmounts.toggle()
    }
}

// MARK: - Mock Data for Preview
extension HomeViewModel {
    static let mockData: DashboardSummary = DashboardSummary(
        currentMonth: MonthSummary(
            totalIncome: 15000000,
            totalExpense: 8500000,
            netAmount: 6500000,
            incomeCount: 3,
            expenseCount: 25,
            savingsRate: 43.3
        ),
        lastMonth: nil,
        topCategories: [
            TopCategory(id: 1, categoryId: 2, categoryName: "Food", totalAmount: 2500000, percentage: 29.4, count: 12),
            TopCategory(id: 2, categoryId: 4, categoryName: "Shopping", totalAmount: 1800000, percentage: 21.2, count: 5),
            TopCategory(id: 3, categoryId: 3, categoryName: "Transport", totalAmount: 1200000, percentage: 14.1, count: 8),
            TopCategory(id: 4, categoryId: 6, categoryName: "Bills", totalAmount: 1000000, percentage: 11.8, count: 3),
            TopCategory(id: 5, categoryId: 5, categoryName: "Entertainment", totalAmount: 800000, percentage: 9.4, count: 4)
        ],
        recentTransactions: [
            RecentTransaction(id: 1, amount: 150000, transactionType: 2, date: "2026-01-23", categoryName: "Food", description: "Lunch at cafe"),
            RecentTransaction(id: 2, amount: 5000000, transactionType: 1, date: "2026-01-22", categoryName: "Salary", description: "Monthly salary"),
            RecentTransaction(id: 3, amount: 75000, transactionType: 2, date: "2026-01-21", categoryName: "Transport", description: "Grab ride home"),
            RecentTransaction(id: 4, amount: 450000, transactionType: 2, date: "2026-01-20", categoryName: "Shopping", description: "Groceries"),
            RecentTransaction(id: 5, amount: 2000000, transactionType: 1, date: "2026-01-19", categoryName: "Freelance", description: "Web project payment")
        ],
        budgetSummary: BudgetSummary(
            totalBudgets: 5,
            activeBudgets: 5,
            exceededBudgets: 1,
            warningBudgets: 2,
            totalBudgeted: 10000000,
            totalSpent: 8500000,
            averageUtilization: 85.0
        )
    )
}
