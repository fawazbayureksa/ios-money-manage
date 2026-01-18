//
//  TransactionTypeSelector.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionTypeSelector: View {
    @Binding var selectedType: TransactionType
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                TransactionTypeButton(
                    type: type,
                    isSelected: selectedType == type,
                    action: { selectedType = type }
                )
            }
        }
    }
}

struct TransactionTypeButton: View {
    let type: TransactionType
    let isSelected: Bool
    let action: () -> Void
    
    private var color: Color {
        type == .income ? .green : .red
    }
    
    private var icon: String {
        type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    VStack {
        TransactionTypeSelector(selectedType: .constant(.income))
        TransactionTypeSelector(selectedType: .constant(.expense))
    }
    .padding()
}
