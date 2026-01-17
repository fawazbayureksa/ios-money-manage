//
//  TransactionListView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionListView: View {
    let transactions: [Transaction]
    var onDelete: ((Transaction) -> Void)?
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(transactions) { transaction in
                TransactionCardView(
                    transaction: transaction,
                    onDelete: { onDelete?(transaction) }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Empty State View

struct TransactionEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your transactions will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        TransactionListView(
            transactions: Transaction.mockData,
            onDelete: { transaction in
                print("Delete: \(transaction.id)")
            }
        )
    }
    .background(Color(.systemGroupedBackground))
}
