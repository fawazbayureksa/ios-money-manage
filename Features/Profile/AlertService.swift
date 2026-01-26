//
//  AlertService.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation

class AlertService {
    static let shared = AlertService()
    
    private init() {}
    
    // MARK: - API Responses
    
    struct ApiResponse<T: Decodable>: Decodable {
        let success: Bool
        let message: String?
        let data: T?
    }
    
    struct SimpleResponse: Decodable {
        let success: Bool
        let message: String?
    }
    
    // MARK: - Get Alerts
    
    func getAlerts(
        page: Int = 1,
        pageSize: Int = 10,
        unreadOnly: Bool = false,
        budgetId: Int? = nil,
        sortBy: String = "created_at",
        sortDir: String = "desc"
    ) async throws -> PaginatedAlerts {
        var components = URLComponents(string: "\(AppConfig.apiBaseURL)/budget-alerts")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize)),
            URLQueryItem(name: "sort_by", value: sortBy),
            URLQueryItem(name: "sort_dir", value: sortDir)
        ]
        
        if unreadOnly {
            queryItems.append(URLQueryItem(name: "unread_only", value: "true"))
        }
        
        if let budgetId = budgetId {
            queryItems.append(URLQueryItem(name: "budget_id", value: String(budgetId)))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch alerts"])
        }
        
        let decoded = try JSONDecoder().decode(ApiResponse<PaginatedAlerts>.self, from: data)
        
        if decoded.success, let alertsData = decoded.data {
            return alertsData
        } else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: decoded.message ?? "Unknown error"])
        }
    }
    
    // MARK: - Mark Alert as Read
    
    func markAsRead(alertId: Int) async throws -> SimpleResponse {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/budget-alerts/\(alertId)/read") else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to mark alert as read"])
        }
        
        let decoded = try JSONDecoder().decode(SimpleResponse.self, from: data)
        return decoded
    }
    
    // MARK: - Mark All Alerts as Read
    
    func markAllAsRead() async throws -> SimpleResponse {
        guard let url = URL(string: "\(AppConfig.apiBaseURL)/budget-alerts/read-all") else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        let token = TokenManager.shared.getToken() ?? ""
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AlertService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to mark all alerts as read"])
        }
        
        let decoded = try JSONDecoder().decode(SimpleResponse.self, from: data)
        return decoded
    }
    
    // MARK: - Get Unread Count
    
    func getUnreadCount() async throws -> Int {
        let result = try await getAlerts(page: 1, pageSize: 1, unreadOnly: true)
        return result.totalItems
    }
}
