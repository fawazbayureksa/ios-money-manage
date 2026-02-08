//
//  AddBudgetViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 23/01/26.
//

import Foundation
import Combine

enum BudgetPeriod: String, CaseIterable {
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        self.rawValue.capitalized
    }
}

@MainActor
final class AddBudgetViewModel: ObservableObject {
    // MARK: - Form Fields
    @Published var amount: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedPeriod: BudgetPeriod = .monthly
    @Published var startDate: Date = Date()
    @Published var alertThreshold: Int = 80
    
    // MARK: - Data
    @Published var categories: [Category] = []
    
    // MARK: - State
    @Published var isLoading = false
    @Published var isLoadingData = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    // MARK: - Validation Errors
    @Published var amountError: String?
    @Published var categoryError: String?
    
    // MARK: - Services
    private let budgetService = BudgetService.shared
    
    // MARK: - Load Data
    
    func loadData() {
        isLoadingData = true
        errorMessage = nil
        
        fetchCategories()
    }
    
    private func fetchCategories() {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories") else {
            isLoadingData = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                defer { self?.isLoadingData = false }
                
                guard let data = data else { return }
                
                struct CategoriesResponse: Decodable {
                    let success: Bool
                    let message: String?
                    let data: [Category]?
                }
                
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
    
    // MARK: - Validation
    
    func validateForm() -> Bool {
        var isValid = true
        
        // Reset errors
        amountError = nil
        categoryError = nil
        
        // Validate amount
        if amount.isEmpty || (Double(amount) ?? 0) <= 0 {
            amountError = "Budget amount must be greater than 0"
            isValid = false
        }
        
        // Validate category
        if selectedCategory == nil {
            categoryError = "Please select a category"
            isValid = false
        }
        
        return isValid
    }
    
    // MARK: - Submit
    
    func submitBudget() async {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let budgetData = BudgetData(
            categoryId: selectedCategory!.id,
            amount: Double(amount) ?? 0,
            period: selectedPeriod.rawValue,
            startDate: dateFormatter.string(from: startDate),
            alertAt: alertThreshold
        )
        
        do {
            _ = try await budgetService.createBudget(budgetData: budgetData)
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Mock Data (for testing)
    
    func loadMockData() {
        categories = Category.mockData
    }
}
