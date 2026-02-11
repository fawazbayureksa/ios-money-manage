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
    
    // MARK: - Pagination Properties
    @Published var currentPage = 1
    @Published var hasMore = true
    @Published var isLoadingMore = false
    
    // MARK: - Filter Properties
    @Published var filterType: TransactionFilterType = .all
    @Published var categoryId: Int?
    @Published var assetId: Int? // V2: Filter by asset ID
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    private let pageSize = 20
    
    // Track total loaded count to prevent duplicates
    private var loadedCount = 0
    
    // MARK: - Filtered Transactions
    var filteredTransactions: [Transaction] {
        transactions
            .filter { transaction in
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
                
                // Filter by asset (if set) - V2
                if let assetId = assetId, transaction.assetId != assetId {
                    return false
                }
                
                return true
            }
            .sorted { first, second in
                // Sort by date (newest first), then by ID (descending)
                if first.date != second.date {
                    return first.date > second.date
                } else {
                    return first.id > second.id
                }
            }
    }
    
    // MARK: - API Response Models
    
    struct TransactionResponse: Decodable {
        let success: Bool
        let message: String?
        let data: [Transaction]?
        let pagination: Pagination?
        
        enum CodingKeys: String, CodingKey {
            case success
            case message
            case data
            case pagination
        }
        
        struct Pagination: Decodable {
            let page: Int
            let pageSize: Int
            let totalItems: Int
            let totalPages: Int
            
            enum CodingKeys: String, CodingKey {
                case page
                case pageSize = "page_size"
                case totalItems = "total_items"
                case totalPages = "total_pages"
            }
            
            var paginationInfo: PaginationInfo {
                PaginationInfo(
                    currentPage: page,
                    totalPages: totalPages,
                    totalItems: totalItems,
                    itemsPerPage: pageSize
                )
            }
        }
    }
    
    struct PaginationInfo {
        let currentPage: Int
        let totalPages: Int
        let totalItems: Int
        let itemsPerPage: Int
    }
    
    struct TransactionListData: Decodable {
        let data: [Transaction]
        let currentPage: Int?
        let lastPage: Int?
        let total: Int?
        
        enum CodingKeys: String, CodingKey {
            case data
            case currentPage = "current_page"
            case lastPage = "last_page"
            case total
        }
    }
    
    // MARK: - Fetch Transactions (V2 API)
    
    func fetchTransactions(reset: Bool = true) {
        print("📄 fetchTransactions called - reset: \(reset), currentPage: \(currentPage)")
        
        if reset {
            currentPage = 1
            hasMore = true
            isLoading = true
            loadedCount = 0
            print("🔄 Reset: currentPage=1, hasMore=true, loadedCount=0")
        } else {
            isLoadingMore = true
            print("⬇️ Loading more: page=\(currentPage + 1)")
        }
        errorMessage = nil
        
        // Use V2 API endpoint
        var urlComponents = URLComponents(string: "\(AppConfig.apiBaseURL)/v2/transactions")
        urlComponents?.queryItems = buildQueryItems()
        
        guard let url = urlComponents?.url else {
            isLoading = false
            isLoadingMore = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("📡 Fetching transactions from V2 API: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isLoadingMore = false
                
                if let error = error {
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        print("✅ Request cancelled - ignoring error")
                        return
                    }
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                // Debug: Print raw response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Raw API Response: \(jsonString)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(TransactionResponse.self, from: data)
                    print("📦 Decoded success: \(decoded.success)")
                    
                    if decoded.success, let responseData = decoded.data {
                        print("📊 Received \(responseData.count) transactions")
                        
                        if reset {
                            // When resetting, replace all transactions with new data
                            self?.transactions = responseData
                            self?.loadedCount = responseData.count
                            print("🔄 Reset - set \(responseData.count) transactions")
                        } else {
                            // When loading more, prevent duplicates by filtering
                            let existingIds = Set(self?.transactions.map { $0.id } ?? [])
                            let newTransactions = responseData.filter { !existingIds.contains($0.id) }
                            print("✅ Filtered duplicates: \(newTransactions.count) unique transactions out of \(responseData.count)")
                            
                            self?.transactions.append(contentsOf: newTransactions)
                            self?.loadedCount += newTransactions.count
                            print("➕ Appended \(newTransactions.count) transactions (total: \(self?.transactions.count ?? 0))")
                        }
                        
                        // Update hasMore based on pagination info
                        if let pagination = decoded.pagination {
                            self?.hasMore = pagination.page < pagination.totalPages
                            print("📄 Pagination: page \(pagination.page)/\(pagination.totalPages), total items: \(pagination.totalItems)")
                        } else {
                            // Fallback: assume more if we got full page
                            self?.hasMore = responseData.count >= (self?.pageSize ?? 20)
                            print("⚠️ No pagination info - using fallback logic")
                        }
                    } else {
                        self?.errorMessage = decoded.message ?? "Failed to fetch transactions"
                        print("❌ API returned success=false")
                    }
                } catch {
                    print("❌ Decode error:", error)
                    self?.errorMessage = "Failed to parse response"
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Transactions for Specific Asset (V2 API)
    
    func fetchTransactionsForAsset(assetId: Int, reset: Bool = true) {
        self.assetId = assetId
        fetchTransactions(reset: reset)
    }
    
    // MARK: - Build Query Items (V2 API)
    
    private func buildQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        items.append(URLQueryItem(name: "page", value: "\(currentPage)"))
        items.append(URLQueryItem(name: "limit", value: "\(pageSize)"))
        
        // Add sorting parameters for consistent ordering
        items.append(URLQueryItem(name: "sort_by", value: "date"))
        items.append(URLQueryItem(name: "order", value: "desc"))
        
        if let typeValue = filterType.transactionTypeValue {
            items.append(URLQueryItem(name: "transaction_type", value: "\(typeValue)"))
        }
        
        if let catId = categoryId {
            items.append(URLQueryItem(name: "category_id", value: "\(catId)"))
        }
        
        // V2: Add asset filter
        if let assetId = assetId {
            items.append(URLQueryItem(name: "asset_id", value: "\(assetId)"))
        }
        
        if let start = startDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            items.append(URLQueryItem(name: "start_date", value: formatter.string(from: start)))
        }
        
        if let end = endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            items.append(URLQueryItem(name: "end_date", value: formatter.string(from: end)))
        }
        
        return items
    }
    
    // MARK: - Load More (Infinite Scroll)
    
    func loadMoreTransactions() {
        guard !isLoading && !isLoadingMore && hasMore else {
            return
        }
        
        currentPage += 1
        fetchTransactions(reset: false)
    }
    
    // MARK: - Refresh
    
    func refreshTransactions() {
        print("🔄 Refresh triggered")
        fetchTransactions(reset: true)
    }
    
    // MARK: - Reset
    
    func resetFilters() {
        filterType = .all
        categoryId = nil
        assetId = nil // V2: Reset asset filter
        startDate = nil
        endDate = nil
        transactions = []
        currentPage = 1
        hasMore = true
        loadedCount = 0
    }
    
    // MARK: - Delete Transaction (V2 API)
    
    func deleteTransaction(_ transaction: Transaction) {
        // Use V2 API endpoint
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/v2/transactions/\(transaction.id)") else {
            errorMessage = "Invalid URL"
            return
        }
        let token = TokenManager.shared.getToken() ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Remove from local list
                self?.transactions.removeAll { $0.id == transaction.id }
                
                print("✅ Transaction deleted successfully (V2 API)")
            }
        }.resume()
    }
    
    // MARK: - Update Transaction (V2 API - New)
    
    func updateTransaction(_ transaction: Transaction, description: String? = nil, categoryId: Int? = nil, assetId: Int? = nil, amount: Double? = nil, transactionType: String? = nil, date: Date? = nil) async {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/v2/transactions/\(transaction.id)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        let token = TokenManager.shared.getToken() ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        struct UpdateRequest: Encodable {
            let description: String?
            let categoryId: Int?
            let assetId: Int?
            let amount: Double?
            let transactionType: String?
            let date: String?
            
            enum CodingKeys: String, CodingKey {
                case description
                case categoryId = "category_id"
                case assetId = "asset_id"
                case amount
                case transactionType = "transaction_type"
                case date
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let updateRequest = UpdateRequest(
            description: description,
            categoryId: categoryId,
            assetId: assetId,
            amount: amount,
            transactionType: transactionType,
            date: date.map { dateFormatter.string(from: $0) }
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(updateRequest)
        } catch {
            errorMessage = "Failed to encode request"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response"
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Transaction updated successfully (V2 API)")
                    // Refresh transactions to get updated data
                    self?.fetchTransactions(reset: true)
                } else {
                    self?.errorMessage = "Failed to update transaction"
                }
            }
        }.resume()
    }
    
    // MARK: - Load Mock Data (for testing)
    
    func loadMockData() {
        transactions = Transaction.mockData
    }
}
