//
//  AddCategoryViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 04/02/26.
//

import Foundation
import SwiftUI

@MainActor
class AddCategoryViewModel: ObservableObject {
    @Published var categoryName = ""
    @Published var categoryDescription = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAlert = false
    
    var isValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespaces).isEmpty &&
        categoryName.count >= 2 &&
        categoryDescription.count <= 200
    }
    
    private let categoryService = CategoryService.shared
    
    func createCategory() async -> Bool {
        guard isValid else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await categoryService.createCategory(
                name: categoryName.trimmingCharacters(in: .whitespaces),
                description: categoryDescription.trimmingCharacters(in: .whitespaces)
            )
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
            return false
        }
    }
    
    func reset() {
        categoryName = ""
        categoryDescription = ""
        errorMessage = nil
        showAlert = false
    }
}
