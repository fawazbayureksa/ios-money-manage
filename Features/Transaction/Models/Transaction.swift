//
//  Transaction.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Decodable {
    let id: Int
    let amount: Double
    let transactionType: Int // 1 = income, 2 = expense
    let categoryId: Int?
    let categoryName: String?
    let bankId: Int?
    let bankName: String?
    let date: String
    let description: String?
    
    // V2: Asset/Wallet related properties
    let assetId: Int?
    let assetName: String?
    let assetIconName: String?
    let assetColor: String? // Hex color string for API compatibility
    let assetBalance: Double? // Raw balance value
    
    var isIncome: Bool {
        transactionType == 1
    }
    
    var formattedAssetBalance: String? {
        guard let balance = assetBalance else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: balance))
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case transactionType = "transaction_type"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case bankId = "bank_id"
        case bankName = "bank_name"
        case date
        case description
        // V2 Asset properties
        case assetId = "asset_id"
        case assetName = "asset_name"
        case assetIconName = "asset_icon_name"
        case assetColor = "asset_color"
        case assetBalance = "asset_balance"
    }
}

// MARK: - Mock Data for Preview
extension Transaction {
    static let mockData: [Transaction] = [
        Transaction(id: 1, amount: 5000000, transactionType: 1, categoryId: 1, categoryName: "Salary", bankId: 1, bankName: "BCA", date: "2026-01-18", description: "Monthly salary", assetId: 1, assetName: "Cash", assetIconName: "banknote", assetColor: "#34C759", assetBalance: 15000000),
        Transaction(id: 2, amount: 150000, transactionType: 2, categoryId: 2, categoryName: "Food", bankId: 2, bankName: "Mandiri", date: "2026-01-17", description: "Lunch with friends", assetId: 2, assetName: "BCA Wallet", assetIconName: "creditcard", assetColor: "#007AFF", assetBalance: 8500000),
        Transaction(id: 3, amount: 2000000, transactionType: 1, categoryId: 7, categoryName: "Freelance", bankId: nil, bankName: nil, date: "2026-01-16", description: nil, assetId: 3, assetName: "GoPay", assetIconName: "yensign.circle", assetColor: "#00AA13", assetBalance: 3200000),
        Transaction(id: 4, amount: 500000, transactionType: 2, categoryId: 4, categoryName: "Shopping", bankId: 3, bankName: "BNI", date: "2026-01-15", description: "New clothes", assetId: 2, assetName: "BCA Wallet", assetIconName: "creditcard", assetColor: "#007AFF", assetBalance: 8000000),
        Transaction(id: 5, amount: 75000, transactionType: 2, categoryId: 3, categoryName: "Transport", bankId: nil, bankName: nil, date: "2026-01-14", description: "Grab ride", assetId: 3, assetName: "GoPay", assetIconName: "yensign.circle", assetColor: "#00AA13", assetBalance: 3125000)
    ]
}
