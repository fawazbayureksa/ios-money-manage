//
//  Category.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation

struct Category: Identifiable, Decodable, Encodable {
    let id: Int
    let categoryName: String
    let description: String
    let userId: Int
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case categoryName = "CategoryName"
        case description = "Description"
        case userId = "UserID"
        case createdAt = "CreatedAt"
        case updatedAt = "UpdatedAt"
    }
}

// MARK: - Mock Data
extension Category {
    static let mockData: [Category] = [
        Category(id: 1, categoryName: "Salary", description: "Monthly salary income", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 2, categoryName: "Food", description: "Food and groceries expenses", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 3, categoryName: "Transport", description: "Transportation expenses", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 4, categoryName: "Shopping", description: "Shopping expenses", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 5, categoryName: "Entertainment", description: "Entertainment and leisure", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 6, categoryName: "Bills", description: "Monthly bills and utilities", userId: 1, createdAt: Date(), updatedAt: nil),
        Category(id: 7, categoryName: "Freelance", description: "Freelance work income", userId: 1, createdAt: Date(), updatedAt: nil)
    ]
}
