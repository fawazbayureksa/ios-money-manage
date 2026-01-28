//
//  WalletScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 28/01/26.
//

import SwiftUI

struct WalletScreenView: View {
    @StateObject private var viewModel = WalletViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.wallets.isEmpty {
                    WalletScreenLoadingView()
                } else if viewModel.wallets.isEmpty {
                    WalletScreenEmptyStateView(onAddWallet: {
                        viewModel.showAddWallet = true
                    })
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if let summary = viewModel.summary {
                                WalletSummaryCard(
                                    summary: summary,
                                    showAmounts: viewModel.showAmounts,
                                    onToggleAmountVisibility: {
                                        viewModel.toggleAmountVisibility()
                                    }
                                )
                            }
                            
                            WalletListSection(
                                wallets: viewModel.wallets,
                                viewModel: viewModel,
                                showAmounts: viewModel.showAmounts
                            )
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        WalletAddButton(action: {
                            viewModel.showAddWallet = true
                        })
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Wallet & Assets")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {
                    viewModel.hasError = false
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .task {
                await viewModel.refresh()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $viewModel.showAddWallet) {
                WalletFormView(
                    mode: .create,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $viewModel.showEditWallet) {
                if let wallet = viewModel.selectedWallet {
                    WalletFormView(
                        mode: .edit(wallet),
                        viewModel: viewModel
                    )
                }
            }
            .confirmationDialog(
                "Delete Wallet",
                isPresented: $viewModel.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let wallet = viewModel.selectedWallet {
                        Task {
                            await viewModel.deleteWallet(wallet)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let wallet = viewModel.selectedWallet {
                    Text("Are you sure you want to delete \(wallet.name)? This action cannot be undone.")
                }
            }
        }
    }
}

private struct WalletScreenLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading wallets...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct WalletScreenEmptyStateView: View {
    let onAddWallet: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wallet.bifold")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 12) {
                Text("No Wallets Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Add your first wallet to start tracking your assets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onAddWallet) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Wallet")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            
            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WalletSummaryCard: View {
    let summary: WalletSummary
    let showAmounts: Bool
    let onToggleAmountVisibility: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(showAmounts ? summary.formattedTotalBalance : "••••••••")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Button(action: onToggleAmountVisibility) {
                        Image(systemName: showAmounts ? "eye" : "eye.slash")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            VStack(spacing: 12) {
                ForEach(summary.currencyBreakdown) { item in
                    CurrencyBreakdownRow(item: item, showAmounts: showAmounts)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.2, blue: 0.6),
                            Color(red: 0.3, green: 0.4, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .purple.opacity(0.3), radius: 12, x: 0, y: 8)
        )
    }
}

private struct CurrencyBreakdownRow: View {
    let item: WalletSummary.CurrencyBreakdown
    let showAmounts: Bool
    
    var body: some View {
        HStack {
            Text(item.currency)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(showAmounts ? item.formattedBalance : "••••••••")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

private struct WalletListSection: View {
    let wallets: [Wallet]
    @ObservedObject var viewModel: WalletViewModel
    let showAmounts: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("My Wallets")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(wallets.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(wallets) { wallet in
                    WalletCardView(
                        wallet: wallet,
                        showAmounts: showAmounts
                    ) {
                        viewModel.selectedWallet = wallet
                        viewModel.showEditWallet = true
                    } onDelete: {
                        viewModel.selectedWallet = wallet
                        viewModel.showDeleteConfirmation = true
                    }
                }
            }
        }
    }
}

private struct WalletCardView: View {
    let wallet: Wallet
    let showAmounts: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(wallet.walletColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: wallet.walletIcon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(wallet.walletColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(wallet.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(wallet.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(wallet.walletColor.opacity(0.1))
                        .foregroundColor(wallet.walletColor)
                        .cornerRadius(8)
                    
                    if let bankName = wallet.bankName {
                        Text(bankName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(showAmounts ? wallet.formattedBalance : "••••••••")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let accountNo = wallet.accountNo {
                HStack {
                    Image(systemName: "number")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Account: \(maskAccountNumber(accountNo))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
    
    private func maskAccountNumber(_ account: String) -> String {
        let count = account.count
        let visible = min(4, count)
        let masked = String(repeating: "•", count: max(0, count - visible))
        let lastFour = String(account.suffix(visible))
        return masked + lastFour
    }
}

private struct WalletAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
}

private enum WalletFormMode {
    case create
    case edit(Wallet)
}

private struct WalletFormView: View {
    let mode: WalletFormMode
    @ObservedObject var viewModel: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type: WalletType = .bank
    @State private var balance = ""
    @State private var currency = "USD"
    @State private var bankName = ""
    @State private var accountNo = ""
    
    private let currencies = ["USD", "EUR", "GBP", "IDR", "JPY", "SGD"]
    
    private var isEdit: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Wallet Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(WalletType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Balance & Currency")) {
                    HStack {
                        Text("Balance")
                        Spacer()
                        TextField("0.00", text: $balance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                }
                
                if type == .bank {
                    Section(header: Text("Bank Details (Optional)")) {
                        TextField("Bank Name", text: $bankName)
                        TextField("Account Number", text: $accountNo)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle(isEdit ? "Edit Wallet" : "Add Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEdit ? "Save" : "Add") {
                        saveWallet()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if case .edit(let wallet) = mode {
                    loadWallet(wallet)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !balance.isEmpty
    }
    
    private func loadWallet(_ wallet: Wallet) {
        name = wallet.name
        type = wallet.type
        balance = String(wallet.balance)
        currency = wallet.currency
        bankName = wallet.bankName ?? ""
        accountNo = wallet.accountNo ?? ""
    }
    
    private func saveWallet() {
        guard let balanceValue = Double(balance) else { return }
        
        Task {
            if case .edit(let wallet) = mode {
                await viewModel.updateWallet(
                    wallet,
                    name: name,
                    type: type,
                    balance: balanceValue,
                    currency: currency,
                    bankName: bankName.isEmpty ? nil : bankName,
                    accountNo: accountNo.isEmpty ? nil : accountNo
                )
            } else {
                await viewModel.createWallet(
                    name: name,
                    type: type,
                    balance: balanceValue,
                    currency: currency,
                    bankName: bankName.isEmpty ? nil : bankName,
                    accountNo: accountNo.isEmpty ? nil : accountNo
                )
            }
            dismiss()
        }
    }
}

#Preview {
    WalletScreenView()
}
