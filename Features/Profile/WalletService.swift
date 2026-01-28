//
//  WalletService.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 28/01/26.
//

import Foundation

final class WalletService {
    static let shared = WalletService()
    private init() {}
    
    private let baseURL = "\(AppConfig.apiBaseURL)/wallets"
    
    func getWallets() async throws -> [Wallet] {
        guard let url = URL(string: baseURL) else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WalletError.httpError(httpResponse.statusCode)
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Wallets API Response: \(jsonString)")
        }
        
        let decoded = try JSONDecoder().decode(WalletResponse.self, from: data)
        return decoded.data
    }
    
    func getWalletSummary() async throws -> WalletSummary {
        guard let url = URL(string: "\(baseURL)/summary") else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WalletError.httpError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(WalletSummary.self, from: data)
    }
    
    func createWallet(_ wallet: CreateWalletRequest) async throws -> Wallet {
        guard let url = URL(string: baseURL) else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(wallet)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WalletError.httpError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(SingleWalletResponse.self, from: data)
        return decoded.data
    }
    
    func updateWallet(id: Int, _ wallet: UpdateWalletRequest) async throws -> Wallet {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(wallet)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WalletError.httpError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(SingleWalletResponse.self, from: data)
        return decoded.data
    }
    
    func deleteWallet(id: Int) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WalletError.httpError(httpResponse.statusCode)
        }
    }
}

enum WalletError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        }
    }
}

struct WalletResponse: Decodable {
    let success: Bool
    let message: String?
    let data: [Wallet]
}

struct SingleWalletResponse: Decodable {
    let success: Bool
    let message: String?
    let data: Wallet
}
