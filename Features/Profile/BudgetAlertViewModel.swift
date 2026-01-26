//
//  BudgetAlertViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import Foundation
import SwiftUI
import Combine

enum AlertFilterType: String, CaseIterable {
    case all = "all"
    case unread = "unread"
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .unread:
            return "Unread"
        }
    }
}

@MainActor
class BudgetAlertViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var alerts: [BudgetAlert] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isLoadingMore = false
    
    @Published var errorMessage: String?
    @Published var hasError = false
    
    @Published var filterType: AlertFilterType = .all
    
    @Published var snackbarMessage: String?
    @Published var showSnackbar = false
    
    // Pagination
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var totalItems: Int = 0
    
    private let pageSize = 10
    
    // MARK: - Services
    private let alertService = AlertService.shared
    
    // MARK: - Computed Properties
    
    var hasUnreadAlerts: Bool {
        alerts.contains { !$0.isRead }
    }
    
    var canLoadMore: Bool {
        currentPage < totalPages
    }
    
    // MARK: - Fetch Alerts
    
    func fetchAlerts(showLoader: Bool = true, page: Int = 1, append: Bool = false) async {
        if showLoader { isLoading = true }
        if append { isLoadingMore = true }
        
        errorMessage = nil
        hasError = false
        
        do {
            let result = try await alertService.getAlerts(
                page: page,
                pageSize: pageSize,
                unreadOnly: filterType == .unread,
                sortBy: "created_at",
                sortDir: "desc"
            )
            
            if append {
                // Deduplicate alerts by id when appending
                let existingIds = Set(alerts.map { $0.id })
                let newAlerts = result.data.filter { !existingIds.contains($0.id) }
                alerts.append(contentsOf: newAlerts)
            } else {
                alerts = result.data
            }
            
            currentPage = result.page
            totalPages = result.totalPages
            totalItems = result.totalItems
            
        } catch {
            if error.localizedDescription.contains("cancelled") {
                return
            }
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    // MARK: - Refresh
    
    func refresh() async {
        isRefreshing = true
        currentPage = 1
        await fetchAlerts(showLoader: false, page: 1, append: false)
        isRefreshing = false
    }
    
    // MARK: - Load More
    
    func loadMore() async {
        guard !isLoadingMore, canLoadMore else { return }
        await fetchAlerts(showLoader: false, page: currentPage + 1, append: true)
    }
    
    // MARK: - Mark as Read
    
    func markAsRead(alertId: Int) async {
        do {
            _ = try await alertService.markAsRead(alertId: alertId)
            
            // Update local state
            if let index = alerts.firstIndex(where: { $0.id == alertId }) {
                alerts[index] = BudgetAlert(
                    id: alerts[index].id,
                    budgetId: alerts[index].budgetId,
                    percentage: alerts[index].percentage,
                    spentAmount: alerts[index].spentAmount,
                    message: alerts[index].message,
                    isRead: true,
                    createdAt: alerts[index].createdAt,
                    categoryId: alerts[index].categoryId,
                    categoryName: alerts[index].categoryName,
                    budgetAmount: alerts[index].budgetAmount
                )
            }
            
            showSnackbar(message: "Alert marked as read")
            
            // Refresh list if in unread filter mode
            if filterType == .unread {
                await refresh()
            }
            
        } catch {
            showSnackbar(message: "Failed to mark alert as read")
        }
    }
    
    // MARK: - Mark All as Read
    
    func markAllAsRead() async {
        do {
            _ = try await alertService.markAllAsRead()
            
            // Update local state
            alerts = alerts.map { alert in
                BudgetAlert(
                    id: alert.id,
                    budgetId: alert.budgetId,
                    percentage: alert.percentage,
                    spentAmount: alert.spentAmount,
                    message: alert.message,
                    isRead: true,
                    createdAt: alert.createdAt,
                    categoryId: alert.categoryId,
                    categoryName: alert.categoryName,
                    budgetAmount: alert.budgetAmount
                )
            }
            
            showSnackbar(message: "Marked all alerts as read")
            
            // Refresh if in unread filter mode
            if filterType == .unread {
                await refresh()
            }
            
        } catch {
            showSnackbar(message: "Failed to mark all alerts as read")
        }
    }
    
    // MARK: - Snackbar
    
    func showSnackbar(message: String) {
        snackbarMessage = message
        withAnimation {
            showSnackbar = true
        }
    }
    
    func hideSnackbar() {
        withAnimation {
            showSnackbar = false
        }
    }
    
    // MARK: - Load Mock Data
    
    func loadMockData() {
        alerts = BudgetAlert.mockData
        totalItems = alerts.count
        totalPages = 1
        currentPage = 1
    }
    
    // MARK: - Initializer
    
    init(useMockData: Bool = false) {
        if useMockData {
            loadMockData()
        }
    }
}
