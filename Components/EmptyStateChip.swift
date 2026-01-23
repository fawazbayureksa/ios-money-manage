//
//  EmptyStateChip.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 23/01/26.
//

import SwiftUI

struct EmptyStateChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.secondary.opacity(0.3))
                    )
            )
    }
}

#Preview {
    EmptyStateChip(text: "No items available")
        .padding()
}
