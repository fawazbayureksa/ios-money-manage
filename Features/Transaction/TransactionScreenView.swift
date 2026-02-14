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
    @State private var hasInitialized = false
    @State private var showAdvancedFilter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.filteredTransactions.isEmpty {
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
                                // Refresh when filter changes
                                viewModel.fetchTransactions()
                            }
                        )
                        .background(Color(.systemBackground))
                        
                        // Active Filter Chips
                        ActiveFilterChipsView(viewModel: viewModel)
                        
                        // Transaction List
                        if viewModel.filteredTransactions.isEmpty {
                            TransactionEmptyView()
                        } else {
                            TransactionListView(
                                viewModel: viewModel,
                                onDelete: { transaction in
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                },
                                onUpdate: { transaction in
                                    // Handle transaction update
                                    // TODO: Implement update functionality
                                }
                            )
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    FilterBadgeView(
                        hasActiveFilters: viewModel.hasActiveAdvancedFilters,
                        action: { showAdvancedFilter = true }
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refreshTransactions() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showAdvancedFilter) {
                AdvancedFilterView(
                    isPresented: $showAdvancedFilter,
                    viewModel: viewModel
                )
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
                // Only fetch once on first appearance
                if !hasInitialized {
                    hasInitialized = true
                    viewModel.fetchTransactions()
                    viewModel.fetchCategories()
                }
            }
        }
    }

}

#Preview {
    TransactionScreenView()
}
