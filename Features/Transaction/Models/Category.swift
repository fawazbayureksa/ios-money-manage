//
//  Category.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation

struct Category: Identifiable, Decodable {
    let id: Int
    let categoryName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case categoryName = "CategoryName"
    }
}

// MARK: - Mock Data
extension Category {
    static let mockData: [Category] = [
        Category(id: 1, categoryName: "Salary"),
        Category(id: 2, categoryName: "Food"),
        Category(id: 3, categoryName: "Transport"),
        Category(id: 4, categoryName: "Shopping"),
        Category(id: 5, categoryName: "Entertainment"),
        Category(id: 6, categoryName: "Bills"),
        Category(id: 7, categoryName: "Freelance")
    ]
}
