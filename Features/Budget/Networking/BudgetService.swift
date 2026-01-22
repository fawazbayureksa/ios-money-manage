//
//  BudgetService.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 22/01/26.
//

import Foundation

class BudgetService {
    static let shared = BudgetService()
    
    private init() {}
    
    func getBudgets() async throws -> [Budget] {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/budgets") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(PaginatedBudgetResponse.self, from: data)
        if decoded.success {
            return decoded.data ?? []
        } else {
            throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
        }
    }
}
