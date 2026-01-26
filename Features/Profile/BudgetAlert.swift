//
//  BudgetAlert.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import SwiftUI

struct BudgetAlert: Identifiable, Decodable {
    let id: Int
    let budgetId: Int
    let percentage: Double
    let spentAmount: Double
    let message: String
    let isRead: Bool
    let createdAt: String
    let categoryId: Int
    let categoryName: String
    let budgetAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case budgetId = "budget_id"
        case percentage
        case spentAmount = "spent_amount"
        case message
        case isRead = "is_read"
        case createdAt = "created_at"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case budgetAmount = "budget_amount"
    }
    
    // Computed property for formatted currency
    var formattedSpentAmount: String {
        formatCurrency(spentAmount)
    }
    
    var formattedBudgetAmount: String {
        formatCurrency(budgetAmount)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp\(Int(value))"
    }
    
    // Alert level based on percentage
    var alertLevel: AlertLevel {
        if percentage >= 100 {
            return .exceeded
        } else if percentage >= 80 {
            return .warning
        } else {
            return .safe
        }
    }
    
    // Alert color
    var alertColor: Color {
        switch alertLevel {
        case .exceeded:
            return .red
        case .warning:
            return .orange
        case .safe:
            return .green
        }
    }
    
    // Alert icon name
    var alertIconName: String {
        switch alertLevel {
        case .exceeded:
            return "alert.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .safe:
            return "info.circle.fill"
        }
    }
    
    // Formatted date
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else {
            return createdAt
        }
        return formatDateRelative(date)
    }
    
    private func formatDateRelative(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        let diffMinutes = Int(diff / 60)
        let diffHours = Int(diff / 3600)
        let diffDays = Int(diff / 86400)
        
        if diffMinutes < 1 {
            return "Just now"
        } else if diffMinutes < 60 {
            return "\(diffMinutes) min\(diffMinutes > 1 ? "s" : "") ago"
        } else if diffHours < 24 {
            return "\(diffHours) hour\(diffHours > 1 ? "s" : "") ago"
        } else if diffDays < 7 {
            return "\(diffDays) day\(diffDays > 1 ? "s" : "") ago"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            dateFormatter.locale = Locale(identifier: "id_ID")
            return dateFormatter.string(from: date)
        }
    }
}

enum AlertLevel {
    case safe      // Green
    case warning   // Orange
    case exceeded  // Red
}

struct PaginatedAlerts: Decodable {
    let data: [BudgetAlert]
    let page: Int
    let pageSize: Int
    let totalItems: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case page
        case pageSize = "page_size"
        case totalItems = "total_items"
        case totalPages = "total_pages"
    }
}

// MARK: - Mock Data

extension BudgetAlert {
    static let mockData: [BudgetAlert] = [
        BudgetAlert(
            id: 1,
            budgetId: 1,
            percentage: 120,
            spentAmount: 600000,
            message: "You have exceeded your budget for Food",
            isRead: false,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
            categoryId: 1,
            categoryName: "Food",
            budgetAmount: 500000
        ),
        BudgetAlert(
            id: 2,
            budgetId: 2,
            percentage: 90,
            spentAmount: 900000,
            message: "You are approaching your budget limit for Transport",
            isRead: false,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)),
            categoryId: 2,
            categoryName: "Transport",
            budgetAmount: 1000000
        ),
        BudgetAlert(
            id: 3,
            budgetId: 3,
            percentage: 75,
            spentAmount: 750000,
            message: "You have used 75% of your budget for Entertainment",
            isRead: true,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-172800)),
            categoryId: 3,
            categoryName: "Entertainment",
            budgetAmount: 1000000
        )
    ]
}
