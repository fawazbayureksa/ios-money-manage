import Foundation
import SwiftUI
import Combine

@MainActor
final class AddCategoryViewModel: ObservableObject {
    @Published var categoryName = ""
    @Published var categoryDescription = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAlert = false
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && categoryDescription.count <= 200
    }
    
    // MARK: - Methods
    
    func createCategory() async -> Bool {
        guard isValid else {
            errorMessage = "Please enter a valid category name."
            showAlert = true
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDescription = categoryDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let _ = try await CategoryService.shared.createCategory(
                name: trimmedName,
                description: trimmedDescription
            )
            
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showAlert = true
            return false
        }
    }
}
