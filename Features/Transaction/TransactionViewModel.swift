//
//  TransactionViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Filter Properties
    @Published var filterType: TransactionFilterType = .all
    @Published var categoryId: Int?
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    // MARK: - Filtered Transactions
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            // Filter by transaction type
            if let typeValue = filterType.transactionTypeValue {
                if transaction.transactionType != typeValue {
                    return false
                }
            }
            
            // Filter by category (if set)
            if let catId = categoryId, transaction.categoryId != catId {
                return false
            }
            
            return true
        }
    }
    
    // MARK: - API Response Models
    
    struct TransactionResponse: Decodable {
        let success: Bool
        let message: String?
        let data: [Transaction]?
    }
    
    // MARK: - Fetch Transactions
    
    func fetchTransactions() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/transactions") else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        print(url)
        var request = URLRequest(url: url)
        let token =  TokenManager.shared.getToken() ?? ""
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
     
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(TransactionResponse.self, from: data)
                    print(decoded)
                    if decoded.success {
                        self?.transactions = decoded.data ?? []
                    } else {
                        self?.errorMessage = decoded.message ?? "Failed to fetch transactions"
                    }
                } catch {
                    print("❌ Decode error:", error)
                    self?.errorMessage = "Failed to parse response"
                }
            }
        }.resume()
    }
    
    // MARK: - Delete Transaction
    
    func deleteTransaction(_ transaction: Transaction) {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/transactions/\(transaction.id)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Add auth token header
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Remove from local list
                self?.transactions.removeAll { $0.id == transaction.id }
            }
        }.resume()
    }
    
    // MARK: - Load Mock Data (for testing)
    
    func loadMockData() {
        transactions = Transaction.mockData
    }
}
