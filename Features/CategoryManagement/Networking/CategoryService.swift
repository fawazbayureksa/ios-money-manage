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
    
    // Custom date decoder to handle multiple date formats
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try ISO8601 with fractional seconds: "2025-12-30T07:45:56.123Z"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try ISO8601 without fractional seconds: "2025-12-30T07:45:56Z"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try ISO8601 with timezone offset: "2025-12-30T07:45:56+00:00"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            // Try RFC3339: "2025-12-30T07:45:56.123456Z"
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
        }
        return decoder
    }
    
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
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/categories") else {
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
        
        do {
            let decoder = CategoryService.createDecoder()
            let decoded = try decoder.decode(ApiResponse<[Category]>.self, from: data)
            if decoded.success, let categories = decoded.data {
                return categories
            } else {
                throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
            }
        } catch let decodingError as DecodingError {
            print("❌ Decoding Error: \(decodingError)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- RAW RESPONSE ---")
                print(jsonString)
                print("-------------------")
            }
            
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
            let decoder = CategoryService.createDecoder()
            let decoded = try decoder.decode(ApiResponse<Category>.self, from: data)
            if decoded.success, let category = decoded.data {
                return category
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
            throw NSError(domain: "CategoryService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response: \(error.localizedDescription)"])
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
