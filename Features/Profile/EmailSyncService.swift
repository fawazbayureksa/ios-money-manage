import Foundation

struct SyncResult: Decodable {
    let total: Int
    let imported: Int
    let skipped: Int
    let failed: Int
}

struct EmailSyncStatus: Decodable {
    let connected: Bool
    let logs: [EmailSyncLog]
    let total: Int
    let page: Int
    let limit: Int
}

struct EmailSyncLog: Decodable, Identifiable {
    let id: Int
    let gmailMessageId: String
    let subject: String
    let fromEmail: String
    let bankName: String
    let amount: Int?
    let assetId: Int?
    let transactionId: Int?
    let status: String
    let errorMessage: String
    let emailDate: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case gmailMessageId = "gmail_message_id"
        case subject
        case fromEmail = "from_email"
        case bankName = "bank_name"
        case amount
        case assetId = "asset_id"
        case transactionId = "transaction_id"
        case status
        case errorMessage = "error_message"
        case emailDate = "email_date"
        case createdAt = "created_at"
    }
}

private struct EmailSyncResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
}

private struct EmailAuthURLData: Decodable {
    let authURL: String

    enum CodingKeys: String, CodingKey {
        case authURL = "auth_url"
    }
}

enum EmailSyncError: LocalizedError {
    case invalidURL
    case unauthenticated
    case invalidResponse
    case httpError(Int, String?)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .unauthenticated:
            return "Please log in first"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, let message):
            return message?.isEmpty == false ? message : "HTTP error: \(code)"
        case .emptyData:
            return "Response data is empty"
        }
    }
}

final class EmailSyncService {
    static let shared = EmailSyncService()

    private init() {}

    private let baseURL = "\(AppConfig.apiBaseURL)/v2/email-sync"

    private func authorizedRequest(path: String, method: String = "GET") throws -> URLRequest {
        guard let token = TokenManager.shared.getToken(), !token.isEmpty else {
            throw EmailSyncError.unauthenticated
        }

        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw EmailSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func decodeResponse<T: Decodable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailSyncError.invalidResponse
        }

        let decoder = JSONDecoder()

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(EmailSyncResponse<EmptyData>.self, from: data).message
            throw EmailSyncError.httpError(httpResponse.statusCode, message)
        }

        let decoded = try decoder.decode(EmailSyncResponse<T>.self, from: data)
        guard decoded.success else {
            throw EmailSyncError.httpError(httpResponse.statusCode, decoded.message)
        }
        guard let payload = decoded.data else {
            throw EmailSyncError.emptyData
        }

        return payload
    }

    private func validateSuccessWithoutData(_ data: Data, _ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailSyncError.invalidResponse
        }

        let decoder = JSONDecoder()

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = try? decoder.decode(EmailSyncResponse<EmptyData>.self, from: data).message
            throw EmailSyncError.httpError(httpResponse.statusCode, message)
        }

        let decoded = try decoder.decode(EmailSyncResponse<EmptyData>.self, from: data)
        guard decoded.success else {
            throw EmailSyncError.httpError(httpResponse.statusCode, decoded.message)
        }
    }

    func getAuthURL() async throws -> String {
        let request = try authorizedRequest(path: "/auth")
        let (data, response) = try await URLSession.shared.data(for: request)
        let payload: EmailAuthURLData = try decodeResponse(data, response)
        return payload.authURL
    }

    func syncEmails() async throws -> SyncResult {
        let request = try authorizedRequest(path: "/sync", method: "POST")
        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeResponse(data, response)
    }

    func getStatus(page: Int = 1, limit: Int = 20) async throws -> EmailSyncStatus {
        let request = try authorizedRequest(path: "/status?page=\(page)&limit=\(limit)")
        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeResponse(data, response)
    }

    func disconnect() async throws {
        let request = try authorizedRequest(path: "/disconnect", method: "DELETE")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateSuccessWithoutData(data, response)
    }
}

private struct EmptyData: Decodable {}
