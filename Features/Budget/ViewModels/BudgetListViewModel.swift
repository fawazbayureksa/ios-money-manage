//
//  BudgetListViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 22/01/26.
//

import Foundation
import Combine

@MainActor
class BudgetListViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let service = BudgetService.shared
    
    func fetchBudgets(showLoader: Bool = true) async {
        if showLoader { isLoading = true }
        errorMessage = nil
        hasError = false
        
        do {
            budgets = try await service.getBudgets()
        } catch {
            if error.localizedDescription.contains("Cancelled") || error.localizedDescription.contains("cancelled") {
                return
            }
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isRefreshing = true
        await fetchBudgets(showLoader: false)
        isRefreshing = false
    }
    
    // For Preview
    init(budgets: [Budget] = []) {
        self.budgets = budgets
    }
}
