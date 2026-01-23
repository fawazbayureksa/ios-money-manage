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
        
        // Debug logging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- BUDGET API RESPONSE ---")
            print(jsonString)
            print("---------------------------")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(PaginatedBudgetResponse.self, from: data)
            if decoded.success {
                return decoded.data?.data ?? []
            } else {
                throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
            }
        } catch let decodingError as DecodingError {
            print("❌ Decoding Error: \(decodingError)")
            
            var errorMessage = "Decoding failed: "
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage += "Type mismatch for \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
            case .valueNotFound(let type, let context):
                errorMessage += "Value not found for \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
            case .keyNotFound(let key, let context):
                errorMessage += "Key not found: '\(key.stringValue)' at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let context):
                errorMessage += "Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
            @unknown default:
                errorMessage += "Unknown decoding error"
            }
            throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        } catch {
            throw error
        }
    }
    
    func createBudget(budgetData: BudgetData) async throws -> Budget {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/budgets") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(budgetData)
        } catch {
            throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug logging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- CREATE BUDGET RESPONSE ---")
            print(jsonString)
            print("-------------------------------")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(CreateBudgetResponse.self, from: data)
            if decoded.success, let budget = decoded.data {
                return budget
            } else {
                throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
            }
        } catch {
            throw NSError(domain: "BudgetService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
    }
    
    func deleteBudget(budgetId: Int) async throws {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/budgets/\(budgetId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

struct CreateBudgetResponse: Decodable {
    let success: Bool
    let message: String?
    let data: Budget?
}

struct BudgetData: Encodable {
    let categoryId: Int
    let amount: Double
    let period: String
    let startDate: String
    let alertAt: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case amount
        case period
        case startDate = "start_date"
        case alertAt = "alert_at"
    }
}
