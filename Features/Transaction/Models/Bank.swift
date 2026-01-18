//
//  Bank.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation

struct Bank: Identifiable, Decodable {
    let id: Int
    let bankName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case bankName = "bank_name"
    }
}

// MARK: - Mock Data
extension Bank {
    static let mockData: [Bank] = [
        Bank(id: 1, bankName: "BCA"),
        Bank(id: 2, bankName: "Mandiri"),
        Bank(id: 3, bankName: "BNI"),
        Bank(id: 4, bankName: "BRI"),
        Bank(id: 5, bankName: "CIMB")
    ]
}
