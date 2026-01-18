//
//  AddTransactionViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import Combine

enum TransactionType: String, CaseIterable {
    case income = "Income"
    case expense = "Expense"
    
    var value: Int {
        self == .income ? 1 : 2
    }
}

@MainActor
final class AddTransactionViewModel: ObservableObject {
    // MARK: - Form Fields
    @Published var amount: String = ""
    @Published var description: String = ""
    @Published var transactionType: TransactionType = .expense
    @Published var selectedCategory: Category?
    @Published var selectedBank: Bank?
    @Published var date: Date = Date()
    
    // MARK: - Data
    @Published var categories: [Category] = []
    @Published var banks: [Bank] = []
    
    // MARK: - State
    @Published var isLoading = false
    @Published var isLoadingData = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    // MARK: - Validation Errors
    @Published var amountError: String?
    @Published var categoryError: String?
    @Published var bankError: String?
    
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    
    // MARK: - API Response Models
    
    struct CategoriesResponse: Decodable {
        let success: Bool
        let message: String?
        let data: [Category]?
    }
    
    struct BanksResponse: Decodable {
        let success: Bool
        let message: String?
        let data: BanksData?
    }
    
    struct BanksData: Decodable {
        let data: [Bank]?
    }
    
    struct CreateTransactionRequest: Encodable {
        let BankID: Int
        let CategoryID: Int
        let Amount: Double
        let Description: String
        let Date: String
        let TransactionType: Int
    }
    
    struct CreateTransactionResponse: Decodable {
        let success: Bool
        let message: String?
    }
    
    // MARK: - Load Data
    
    func loadData() {
        isLoadingData = true
        errorMessage = nil
        
        let group = DispatchGroup()
        
        // Fetch Categories
        group.enter()
        fetchCategories { group.leave() }
        
        // Fetch Banks
        group.enter()
        fetchBanks { group.leave() }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoadingData = false
        }
    }
    
    private func fetchCategories(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories") else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer { completion() }
                
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    if decoded.success {
                        self?.categories = decoded.data ?? []
                    }
                } catch {
                    print("❌ Categories decode error:", error)
                }
            }
        }.resume()
    }
    
    private func fetchBanks(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/banks?page=1&page_size=100") else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer { completion() }
                
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(BanksResponse.self, from: data)
                    if decoded.success {
                        self?.banks = decoded.data?.data ?? []
                    }
                } catch {
                    print("❌ Banks decode error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: - Validation
    
    func validateForm() -> Bool {
        var isValid = true
        
        // Reset errors
        amountError = nil
        categoryError = nil
        bankError = nil
        
        // Validate amount
        if amount.isEmpty || (Double(amount) ?? 0) <= 0 {
            amountError = "Amount must be greater than 0"
            isValid = false
        }
        
        // Validate category
        if selectedCategory == nil {
            categoryError = "Please select a category"
            isValid = false
        }
        
        // Validate bank
        if selectedBank == nil {
            bankError = "Please select a bank"
            isValid = false
        }
        
        return isValid
    }
    
    // MARK: - Submit
    
    func submitTransaction() {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/transaction") else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        let dateFormatter = ISO8601DateFormatter()
        print(dateFormatter.string(from: date));
        let transactionData = CreateTransactionRequest(
            BankID: selectedBank!.id,
            CategoryID: selectedCategory!.id,
            Amount: Double(amount) ?? 0,
            Description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            Date: dateFormatter.string(from: date),
            TransactionType: transactionType.value
        )
    
        do {
            request.httpBody = try JSONEncoder().encode(transactionData)
        } catch {
            isLoading = false
            errorMessage = "Failed to encode request"
            return
        }
        
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
                
                // Debug: Print raw response
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📥 Raw response:", rawResponse)
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 Status code:", httpResponse.statusCode)
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                        return
                    }
                }
                
                do {
                    let decoded = try JSONDecoder().decode(CreateTransactionResponse.self, from: data)
                    
                    if decoded.success {
                        self?.showSuccessAlert = true
                    } else {
                        self?.errorMessage = decoded.message ?? "Failed to create transaction"
                    }
                } catch {
                    print("❌ Decode error:", error)
                    self?.errorMessage = "Failed to parse response"
                }
            }
        }.resume()
    }
    
    // MARK: - Mock Data (for testing)
    
    func loadMockData() {
        categories = Category.mockData
        banks = Bank.mockData
    }
}
