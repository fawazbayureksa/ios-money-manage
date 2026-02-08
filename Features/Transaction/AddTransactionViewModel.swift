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
    @Published var selectedBank: Bank? // V1 - Legacy
    @Published var selectedWallet: Wallet? // V2 - Use Wallet as Asset
    @Published var date: Date = Date()
    
    // MARK: - Data
    @Published var categories: [Category] = []
    @Published var banks: [Bank] = [] // V1 - Legacy
    @Published var wallets: [Wallet] = [] // V2 - Wallets/Assets
    
    // MARK: - State
    @Published var isLoading = false
    @Published var isLoadingData = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    // MARK: - Validation Errors
    @Published var amountError: String?
    @Published var categoryError: String?
    @Published var bankError: String? // V1
    @Published var walletError: String? // V2
    
    // MARK: - Callbacks
    var onSuccess: (() -> Void)?
    
    // MARK: - API Version Control
    private let useV2API = true // Set to false to use V1 API for backward compatibility
    
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
    
    struct WalletsResponse: Decodable {
        let success: Bool
        let message: String?
        let data: [Wallet]?
    }
    
    // V2 Request
    struct CreateTransactionRequestV2: Encodable {
        let description: String?
        let categoryId: Int
        let assetId: Int
        let amount: Double
        let transactionType: String
        let date: String
        
        enum CodingKeys: String, CodingKey {
            case description
            case categoryId = "category_id"
            case assetId = "asset_id"
            case amount
            case transactionType = "transaction_type"
            case date
        }
    }
    
    // V1 Request (Legacy)
    struct CreateTransactionRequestV1: Encodable {
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
        
        // Fetch Assets based on API version
        if useV2API {
            group.enter()
            fetchWallets { group.leave() }
        } else {
            group.enter()
            fetchBanks { group.leave() }
        }
        
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
                    let decoder = CategoryService.createDecoder()
                    let decoded = try decoder.decode(CategoriesResponse.self, from: data)
                    if decoded.success {
                        self?.categories = decoded.data ?? []
                    }
                } catch {
                    print("❌ Categories decode error:", error)
                }
            }
        }.resume()
    }
    
    // V1: Fetch Banks
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
    
    // V2: Fetch Wallets (Assets)
    private func fetchWallets(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/wallets") else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer { completion() }
                
                guard let data = data else { return }
                
                do {
                    let decoded = try JSONDecoder().decode(WalletsResponse.self, from: data)
                    if decoded.success {
                        self?.wallets = decoded.data ?? []
                        print("✅ Fetched \(self?.wallets.count ?? 0) wallets (V2)")
                    }
                } catch {
                    print("❌ Wallets decode error:", error)
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
        walletError = nil
        
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
        
        // Validate asset (Bank or Wallet)
        if useV2API {
            if selectedWallet == nil {
                walletError = "Please select a wallet/asset"
                isValid = false
            }
        } else {
            if selectedBank == nil {
                bankError = "Please select a bank"
                isValid = false
            }
        }
        
        return isValid
    }
    
    // MARK: - Submit Transaction
    
    func submitTransaction() {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let baseURL = useV2API ? "\(AppConfig.apiBaseURL)/v2/transactions" : "\(AppConfig.apiBaseURL)/transaction"
        
        guard let url = URL(string: baseURL) else {
            isLoading = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            if useV2API {
                // V2 API: Use asset_id and string transaction_type
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let transactionData = CreateTransactionRequestV2(
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    categoryId: selectedCategory!.id,
                    assetId: selectedWallet!.id,
                    amount: Double(amount) ?? 0,
                    transactionType: transactionType.rawValue,
                    date: dateFormatter.string(from: date)
                )
                
                request.httpBody = try JSONEncoder().encode(transactionData)
                print("📤 Sending V2 request to: \(url.absoluteString)")
            } else {
                // V1 API: Use BankID and integer TransactionType
                let dateFormatter = ISO8601DateFormatter()
                
                let transactionData = CreateTransactionRequestV1(
                    BankID: selectedBank!.id,
                    CategoryID: selectedCategory!.id,
                    Amount: Double(amount) ?? 0,
                    Description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    Date: dateFormatter.string(from: date),
                    TransactionType: transactionType.value
                )
                
                request.httpBody = try JSONEncoder().encode(transactionData)
                print("📤 Sending V1 request to: \(url.absoluteString)")
            }
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
                    
                    // Handle specific V2 error: Insufficient balance
                    if httpResponse.statusCode == 400 || httpResponse.statusCode == 422 {
                        if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                           let message = errorResponse["message"] {
                            if message.contains("Insufficient balance") || message.contains("insufficient") {
                                self?.errorMessage = "Insufficient balance in the selected wallet/asset"
                                return
                            }
                        }
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                        return
                    }
                }
                
                do {
                    let decoded = try JSONDecoder().decode(CreateTransactionResponse.self, from: data)
                    
                    if decoded.success {
                        print("✅ Transaction created successfully (V\(self?.useV2API == true ? "2" : "1") API)")
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
        wallets = Wallet.mockData
    }
}
