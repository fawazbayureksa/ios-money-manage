//
//  Budget.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 22/01/26.
//

import Foundation

struct Budget: Decodable, Identifiable {
    let id: Int
    let category_id: Int
    let category_name: String?
    let amount: Double
    let period: String // "monthly" | "yearly"
    let alert_at: Int
    let spent_amount: Double?
    let remaining_amount: Double?
    let percentage_used: Double?
    let status: String? // "safe" | "warning" | "exceeded"
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR" // Adjust based on requirement
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp\(amount)"
    }
    
    var formattedSpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: NSNumber(value: spent_amount ?? 0)) ?? "Rp\(spent_amount ?? 0)"
    }
}

struct PaginatedBudgetResponse: Decodable {
    let success: Bool
    let message: String?
    let data: [Budget]?
}

extension Budget {
    static var mockData: [Budget] {
        [
            Budget(id: 1, category_id: 1, category_name: "Food", amount: 2000000, period: "monthly", alert_at: 80, spent_amount: 1500000, remaining_amount: 500000, percentage_used: 75, status: "safe"),
            Budget(id: 2, category_id: 2, category_name: "Transport", amount: 1000000, period: "monthly", alert_at: 80, spent_amount: 900000, remaining_amount: 100000, percentage_used: 90, status: "warning"),
            Budget(id: 3, category_id: 3, category_name: "Entertainment", amount: 500000, period: "monthly", alert_at: 80, spent_amount: 600000, remaining_amount: -100000, percentage_used: 120, status: "exceeded")
        ]
    }
}
