//
//  Wallet.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 28/01/26.
//

import Foundation
import SwiftUI

struct Wallet: Identifiable, Decodable, Encodable {
    let id: Int
    let userId: Int
    let name: String
    let type: WalletType
    let balance: Double
    let currency: String
    let bankName: String?
    let accountNo: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case balance
        case currency
        case bankName = "bank_name"
        case accountNo = "account_no"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: balance)) ?? "\(currency) \(balance)"
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else {
            return createdAt
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        return displayFormatter.string(from: date)
    }
    
    var walletIcon: String {
        switch type {
        case .bank:
            return "building.columns.fill"
        case .cash:
            return "banknote.fill"
        case .card:
            return "creditcard.fill"
        case .onlineWallet:
            return "globe"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "wallet.pass.fill"
        }
    }
    
    var walletColor: Color {
        switch type {
        case .bank:
            return .blue
        case .cash:
            return .green
        case .card:
            return .purple
        case .onlineWallet:
            return .orange
        case .investment:
            return .indigo
        case .other:
            return .gray
        }
    }
    
    static let mockData: [Wallet] = [
        Wallet(
            id: 1,
            userId: 1,
            name: "Main Checking",
            type: .bank,
            balance: 5420.50,
            currency: "USD",
            bankName: "Chase Bank",
            accountNo: "1234567890",
            createdAt: "2024-01-15T10:30:00Z",
            updatedAt: "2024-01-20T14:22:00Z"
        ),
        Wallet(
            id: 2,
            userId: 1,
            name: "Cash Wallet",
            type: .cash,
            balance: 350.00,
            currency: "USD",
            bankName: nil,
            accountNo: nil,
            createdAt: "2024-01-10T08:15:00Z",
            updatedAt: "2024-01-25T09:45:00Z"
        ),
        Wallet(
            id: 3,
            userId: 1,
            name: "Credit Card",
            type: .card,
            balance: -1200.00,
            currency: "USD",
            bankName: "American Express",
            accountNo: "4111111111111111",
            createdAt: "2024-01-05T16:20:00Z",
            updatedAt: "2024-01-22T11:30:00Z"
        ),
        Wallet(
            id: 4,
            userId: 1,
            name: "PayPal",
            type: .onlineWallet,
            balance: 875.25,
            currency: "USD",
            bankName: nil,
            accountNo: nil,
            createdAt: "2024-01-12T13:00:00Z",
            updatedAt: "2024-01-23T15:10:00Z"
        ),
        Wallet(
            id: 5,
            userId: 1,
            name: "Investment Account",
            type: .investment,
            balance: 12500.00,
            currency: "USD",
            bankName: "Fidelity",
            accountNo: "987654321",
            createdAt: "2023-12-01T09:00:00Z",
            updatedAt: "2024-01-24T10:05:00Z"
        )
    ]
}

enum WalletType: String, Codable, CaseIterable {
    case bank = "Bank"
    case cash = "Cash"
    case card = "Card"
    case onlineWallet = "Online Wallet"
    case investment = "Investment"
    case other = "Other"
    
    var displayName: String {
        rawValue
    }
    
    var icon: String {
        switch self {
        case .bank:
            return "building.columns.fill"
        case .cash:
            return "banknote.fill"
        case .card:
            return "creditcard.fill"
        case .onlineWallet:
            return "globe"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "wallet.pass.fill"
        }
    }
}

struct WalletSummary: Decodable {
    let totalBalance: Double
    let currencyBreakdown: [CurrencyBreakdown]
    
    enum CodingKeys: String, CodingKey {
        case totalBalance = "total_balance"
        case currencyBreakdown = "currency_breakdown"
    }
    
    struct CurrencyBreakdown: Identifiable, Decodable {
        let id = UUID()
        let currency: String
        let balance: Double
        let walletCount: Int
        
        enum CodingKeys: String, CodingKey {
            case currency
            case balance
            case walletCount = "wallet_count"
        }
        
        var formattedBalance: String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: balance)) ?? "\(currency) \(balance)"
        }
    }
    
    var formattedTotalBalance: String {
        if currencyBreakdown.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
        }
        
        if currencyBreakdown.count == 1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyBreakdown[0].currency
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: totalBalance)) ?? "\(currencyBreakdown[0].currency) \(totalBalance)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "0.00"
    }
}

struct CreateWalletRequest: Encodable {
    let name: String
    let type: String
    let balance: Double
    let currency: String
    let bankName: String?
    let accountNo: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case balance
        case currency
        case bankName = "bank_name"
        case accountNo = "account_no"
    }
}

struct UpdateWalletRequest: Encodable {
    let name: String?
    let type: String?
    let balance: Double?
    let currency: String?
    let bankName: String?
    let accountNo: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case balance
        case currency
        case bankName = "bank_name"
        case accountNo = "account_no"
    }
}
