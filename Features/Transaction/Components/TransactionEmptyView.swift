//
//  TransactionEmptyView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Transactions Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your transactions will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TransactionEmptyView()
}
