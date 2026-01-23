//
//  DashboardModels.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 23/01/26.
//

import Foundation

struct MonthSummary: Decodable {
    let totalIncome: Double
    let totalExpense: Double
    let netAmount: Double
    let incomeCount: Int
    let expenseCount: Int
    let savingsRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
        case netAmount = "net_amount"
        case incomeCount = "income_count"
        case expenseCount = "expense_count"
        case savingsRate = "savings_rate"
    }
    
    var formattedIncome: String {
        formatCurrency(totalIncome)
    }
    
    var formattedExpense: String {
        formatCurrency(totalExpense)
    }
    
    var formattedNetAmount: String {
        formatCurrency(netAmount)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp0"
    }
}

struct TopCategory: Decodable, Identifiable {
    let id: Int?
    let categoryId: Int?
    let categoryName: String
    let totalAmount: Double
    let percentage: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case categoryName = "category_name"
        case totalAmount = "total_amount"
        case percentage
        case count
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "Rp0"
    }
}

struct BudgetSummary: Decodable {
    let totalBudgets: Int
    let activeBudgets: Int
    let exceededBudgets: Int
    let warningBudgets: Int
    let totalBudgeted: Double
    let totalSpent: Double
    let averageUtilization: Double
    
    enum CodingKeys: String, CodingKey {
        case totalBudgets = "total_budgets"
        case activeBudgets = "active_budgets"
        case exceededBudgets = "exceeded_budgets"
        case warningBudgets = "warning_budgets"
        case totalBudgeted = "total_budgeted"
        case totalSpent = "total_spent"
        case averageUtilization = "average_utilization"
    }
    
    var formattedTotalSpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalSpent)) ?? "Rp0"
    }
    
    var formattedTotalBudgeted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalBudgeted)) ?? "Rp0"
    }
}

struct DashboardSummary: Decodable {
    let currentMonth: MonthSummary
    let lastMonth: MonthSummary?
    let topCategories: [TopCategory]
    let recentTransactions: [RecentTransaction]
    let budgetSummary: BudgetSummary?
    
    enum CodingKeys: String, CodingKey {
        case currentMonth = "current_month"
        case lastMonth = "last_month"
        case topCategories = "top_categories"
        case recentTransactions = "recent_transactions"
        case budgetSummary = "budget_summary"
    }
}

struct RecentTransaction: Decodable, Identifiable {
    let id: Int
    let amount: Double
    let transactionType: Int
    let date: String
    let categoryName: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case transactionType = "transaction_type"
        case date
        case categoryName = "category_name"
        case description
    }
    
    var isIncome: Bool {
        transactionType == 1
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        let value = formatter.string(from: NSNumber(value: amount)) ?? "Rp0"
        return isIncome ? "+\(value)" : value
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: date) {
            let displayFormatter = RelativeDateTimeFormatter()
            displayFormatter.unitsStyle = .short
            return displayFormatter.localizedString(for: date, relativeTo: Date())
        }
        return date
    }
}
