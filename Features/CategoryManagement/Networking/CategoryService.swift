//
//  CategoryService.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 04/02/26.
//

import Foundation

class CategoryService {
    static let shared = CategoryService()
    
    private init() {}
    
    struct ApiResponse<T: Decodable>: Decodable {
        let success: Bool
        let message: String?
        let data: T?
    }
    
    struct CategoryListResponse: Decodable {
        let categories: [Category]
    }
    
    struct CreateCategoryRequest: Encodable {
        let categoryName: String
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case categoryName = "CategoryName"
            case description = "Description"
        }
    }
    
    func getCategories() async throws -> [Category] {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories?page_size=100") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- CATEGORIES API RESPONSE ---")
            print(jsonString)
            print("-------------------------------")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<CategoryListResponse>.self, from: data)
            if decoded.success, let categoryList = decoded.data {
                return categoryList.categories
            } else {
                throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
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
            throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        } catch {
            throw error
        }
    }
    
    func createCategory(name: String, description: String) async throws -> Category {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let createRequest = CreateCategoryRequest(categoryName: name, description: description)
        
        do {
            request.httpBody = try JSONEncoder().encode(createRequest)
        } catch {
            throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("--- CREATE CATEGORY RESPONSE ---")
            print(jsonString)
            print("------------------------------")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<Category>.self, from: data)
            if decoded.success, let category = decoded.data {
                return category
            } else {
                throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
            }
        } catch {
            throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
    }
    
    func deleteCategory(categoryId: Int) async throws {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories/\(categoryId)") else {
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
