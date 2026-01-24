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
                } else {
                    VStack(spacing: 0) {
                        // Filter View
                        TransactionFilterView(
                            selectedFilter: $viewModel.filterType,
                            onFilterChanged: { filter in
                                // Reset other filters when "All" is selected
                                if filter == .all {
                                    viewModel.categoryId = nil
                                    viewModel.startDate = nil
                                    viewModel.endDate = nil
                                }
                            }
                        )
                        .background(Color(.systemBackground))
                        
                        // Transaction List
                        if viewModel.filteredTransactions.isEmpty {
                            TransactionEmptyView()
                        } else {
                            TransactionListView(
                                viewModel: viewModel,
                                onDelete: { transaction in
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                }
                            )
                            .padding(.vertical, 16)
                        }
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
                 viewModel.fetchTransactions()
            }
        }
    }

}

#Preview {
    TransactionScreenView()
}
