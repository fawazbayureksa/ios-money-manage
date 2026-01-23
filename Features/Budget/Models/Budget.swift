//
//  Budget.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 22/01/26.
//

import Foundation

struct Budget: Decodable, Identifiable {
    let id: Int
    let categoryId: Int
    let categoryName: String?
    let amount: Double
    let period: String? // "monthly" | "yearly"
    let alertAt: Int?
    let spentAmount: Double?
    let remainingAmount: Double?
    let percentageUsed: Double?
    let status: String? // "safe" | "warning" | "exceeded"
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case categoryName = "category_name"
        case amount
        case period
        case alertAt = "alert_at"
        case spentAmount = "spent_amount"
        case remainingAmount = "remaining_amount"
        case percentageUsed = "percentage_used"
        case status
    }
    
    var formattedAmount: String {
        formatCurrency(amount)
    }
    
    var formattedSpent: String {
        formatCurrency(spentAmount ?? 0)
    }
    
    var formattedRemaining: String {
        formatCurrency(abs(remainingAmount ?? 0))
    }
    
    var formattedOver: String {
        formatCurrency(abs(remainingAmount ?? 0))
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: NSNumber(value: value)) ?? "Rp\(Int(value))"
    }
}

struct PaginatedBudgetResponse: Decodable {
    let success: Bool
    let message: String?
    let data: BudgetListData?
}

struct BudgetListData: Decodable {
    let data: [Budget]?
    // Add other pagination fields if needed
    let currentPage: Int?
    let lastPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case currentPage = "current_page"
        case lastPage = "last_page"
    }
}

extension Budget {
    static var mockData: [Budget] {
        [
            Budget(id: 1, categoryId: 1, categoryName: "Food", amount: 2000000, period: "monthly", alertAt: 80, spentAmount: 1500000, remainingAmount: 500000, percentageUsed: 75, status: "safe"),
            Budget(id: 2, categoryId: 2, categoryName: "Transport", amount: 1000000, period: "monthly", alertAt: 80, spentAmount: 900000, remainingAmount: 100000, percentageUsed: 90, status: "warning"),
            Budget(id: 3, categoryId: 3, categoryName: "Entertainment", amount: 500000, period: "monthly", alertAt: 80, spentAmount: 600000, remainingAmount: -100000, percentageUsed: 120, status: "exceeded")
        ]
    }
}
