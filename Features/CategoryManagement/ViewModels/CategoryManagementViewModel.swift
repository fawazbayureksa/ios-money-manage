//
//  CategoryManagementViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 04/02/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CategoryManagementViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false
    @Published var categoryToDelete: Category?
    @Published var scrollToTop = false
    
    var showingError: Bool {
        errorMessage != nil
    }
    
    private let categoryService = CategoryService.shared
    
    func fetchCategories() async {
        isLoading = true
        
        do {
            categories = try await categoryService.getCategories()
            errorMessage = nil
        } catch is CancellationError {
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshCategories() async {
        await fetchCategories()
        try? await Task.sleep(nanoseconds: 100_000_000)
        scrollToTop.toggle()
    }
    
    func deleteCategory() async {
        guard let category = categoryToDelete else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await categoryService.deleteCategory(categoryId: category.id)
            categories.removeAll { $0.id == category.id }
            errorMessage = nil
            categoryToDelete = nil
            showDeleteConfirmation = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func confirmDelete(category: Category) {
        categoryToDelete = category
        showDeleteConfirmation = true
    }
}
