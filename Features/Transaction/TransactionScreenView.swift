//
//  TransactionScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionScreenView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.transactions.isEmpty {
                    TransactionEmptyView()
                } else {
                    ScrollView {
                        TransactionListView(
                            transactions: viewModel.transactions,
                            onDelete: { transaction in
                                transactionToDelete = transaction
                                showDeleteAlert = true
                            }
                        )
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.fetchTransactions() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        viewModel.deleteTransaction(transaction)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this transaction?")
            }
            .onAppear {
                // Use mock data for now, replace with fetchTransactions() when API is ready
//                viewModel.loadMockData()
                 viewModel.fetchTransactions()
            }
        }
    }
}

#Preview {
    TransactionScreenView()
}
