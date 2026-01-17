//
//  Transaction.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation

struct Transaction: Identifiable, Decodable {
    let id: Int
    let amount: Double
    let transactionType: Int // 1 = income, 2 = expense
    let categoryName: String?
    let bankName: String?
    let date: String
    let description: String?
    
    var isIncome: Bool {
        transactionType == 1
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case transactionType = "transaction_type"
        case categoryName = "category_name"
        case bankName = "bank_name"
        case date
        case description
    }
}

// MARK: - Mock Data for Preview
extension Transaction {
    static let mockData: [Transaction] = [
        Transaction(id: 1, amount: 5000000, transactionType: 1, categoryName: "Salary", bankName: "BCA", date: "2026-01-18", description: "Monthly salary"),
        Transaction(id: 2, amount: 150000, transactionType: 2, categoryName: "Food", bankName: "Mandiri", date: "2026-01-17", description: "Lunch with friends"),
        Transaction(id: 3, amount: 2000000, transactionType: 1, categoryName: "Freelance", bankName: nil, date: "2026-01-16", description: nil),
        Transaction(id: 4, amount: 500000, transactionType: 2, categoryName: "Shopping", bankName: "BNI", date: "2026-01-15", description: "New clothes"),
        Transaction(id: 5, amount: 75000, transactionType: 2, categoryName: "Transport", bankName: nil, date: "2026-01-14", description: "Grab ride")
    ]
}
