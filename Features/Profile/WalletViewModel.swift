//
//  WalletViewModel.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 28/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var summary: WalletSummary?
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    @Published var showAddWallet = false
    @Published var showEditWallet = false
    @Published var selectedWallet: Wallet?
    @Published var showDeleteConfirmation = false
    
    // Show/hide amounts toggle
    @Published var showAmounts = false
    
    init() {}
    
    private let service = WalletService.shared
    
    func fetchWallets(showLoader: Bool = true) async {
        if showLoader { isLoading = true }
        errorMessage = nil
        hasError = false
        
        do {
            let fetchedWallets = try await service.getWallets()
            print("✅ Fetched \(fetchedWallets.count) wallets")
            for wallet in fetchedWallets {
                print("  - \(wallet.name): \(wallet.balance) \(wallet.currency)")
            }
            wallets = fetchedWallets
            calculateSummary()
        } catch {
            // Ignore cancellation errors during refresh
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return
            }
            print("❌ Error fetching wallets: \(error)")
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
    }
    
    func calculateSummary() {
        let currencyGroups = Dictionary(grouping: wallets) { $0.currency }
        
        var breakdown: [WalletSummary.CurrencyBreakdown] = []
        
        for (currency, walletsInCurrency) in currencyGroups {
            let totalBalance = walletsInCurrency.reduce(0) { $0 + $1.balance }
            breakdown.append(
                WalletSummary.CurrencyBreakdown(
                    currency: currency,
                    balance: totalBalance,
                    walletCount: walletsInCurrency.count
                )
            )
            print("💰 Currency \(currency): \(totalBalance) (\(walletsInCurrency.count) wallets)")
        }
        
        let totalBalance = wallets.reduce(0) { $0 + $1.balance }
        print("📊 Total Balance: \(totalBalance)")
        
        summary = WalletSummary(
            totalBalance: totalBalance,
            currencyBreakdown: breakdown
        )
    }
    
    func fetchSummary() async {
        calculateSummary()
    }
    
    func createWallet(name: String, type: WalletType, balance: Double, currency: String, bankName: String?, accountNo: String?) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let request = CreateWalletRequest(
            name: name,
            type: type.rawValue,
            balance: balance,
            currency: currency,
            bankName: bankName,
            accountNo: accountNo
        )
        
        do {
            let newWallet = try await service.createWallet(request)
            wallets.append(newWallet)
            calculateSummary()
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
    }
    
    func updateWallet(_ wallet: Wallet, name: String, type: WalletType, balance: Double, currency: String, bankName: String?, accountNo: String?) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        let request = UpdateWalletRequest(
            name: name,
            type: type.rawValue,
            balance: balance,
            currency: currency,
            bankName: bankName,
            accountNo: accountNo
        )
        
        do {
            let updatedWallet = try await service.updateWallet(id: wallet.id, request)
            if let index = wallets.firstIndex(where: { $0.id == wallet.id }) {
                wallets[index] = updatedWallet
            }
            calculateSummary()
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
    }
    
    func deleteWallet(_ wallet: Wallet) async {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        do {
            try await service.deleteWallet(id: wallet.id)
            wallets.removeAll { $0.id == wallet.id }
            calculateSummary()
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isRefreshing = true
        await fetchWallets(showLoader: false)
        isRefreshing = false
    }
    
    func toggleAmountVisibility() {
        showAmounts.toggle()
    }
    
    var totalWallets: Int {
        wallets.count
    }
    
    var totalBalance: Double {
        wallets.reduce(0) { $0 + $1.balance }
    }
    
    var formattedTotalBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }
}

