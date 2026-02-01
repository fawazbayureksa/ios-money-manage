//
//  TransactionListView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionViewModel
    var onDelete: ((Transaction) -> Void)?
    var onUpdate: ((Transaction) -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.filteredTransactions) { transaction in
                    TransactionCardView(
                        transaction: transaction,
                        onDelete: { onDelete?(transaction) },
                        onUpdate: { onUpdate?(transaction) }
                    )
                    .onAppear {
                        // Trigger load more when the last item appears
                        if transaction.id == viewModel.transactions.last?.id {
                            print("📜 Last item appeared - checking if should load more")
                            if viewModel.hasMore && !viewModel.isLoadingMore {
                                print("📜 Loading more transactions...")
                                viewModel.loadMoreTransactions()
                            }
                        }
                    }
                }
                
                // Load more indicator
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                }
                
                // End of list indicator
                if !viewModel.hasMore && !viewModel.filteredTransactions.isEmpty {
                    Text("No more transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .refreshable {
            viewModel.refreshTransactions()
        }
        .padding(.horizontal, 16)
    }
}
