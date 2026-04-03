import Foundation
import UIKit
import Combine

@MainActor
final class EmailSyncViewModel: ObservableObject {
    @Published var connected = false
    @Published var logs: [EmailSyncLog] = []
    @Published var total = 0
    @Published var page = 1
    @Published var limit = 20
    @Published var isLoading = false
    @Published var isConnecting = false
    @Published var syncing = false
    @Published var syncResult: SyncResult?
    @Published var errorMessage: String?

    private let service = EmailSyncService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: .emailSyncConnected)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadStatus()
                }
            }
            .store(in: &cancellables)
    }

    func loadStatus(page: Int = 1, limit: Int = 20) async {
        isLoading = true
        errorMessage = nil

        do {
            let status = try await service.getStatus(page: page, limit: limit)
            connected = status.connected
            logs = status.logs
            total = status.total
            self.page = status.page
            self.limit = status.limit
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func connect() async {
        isConnecting = true
        errorMessage = nil

        do {
            let authURLString = try await service.getAuthURL()
            guard let authURL = URL(string: authURLString) else {
                isConnecting = false
                errorMessage = "Invalid OAuth URL"
                return
            }

            let canOpen = UIApplication.shared.canOpenURL(authURL)
            if canOpen {
                await UIApplication.shared.open(authURL)
            } else {
                errorMessage = "Unable to open OAuth URL"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isConnecting = false
    }

    func sync() async {
        syncing = true
        syncResult = nil
        errorMessage = nil

        do {
            let result = try await service.syncEmails()
            syncResult = result
            await loadStatus(page: page, limit: limit)
        } catch {
            errorMessage = error.localizedDescription
        }

        syncing = false
    }

    func disconnect() async {
        errorMessage = nil

        do {
            try await service.disconnect()
            connected = false
            logs = []
            total = 0
            syncResult = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
