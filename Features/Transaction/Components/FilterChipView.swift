//
//  FilterChipView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var selectedColor: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? selectedColor : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? selectedColor : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Filter Type Enum

enum TransactionFilterType: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .income: return .green
        case .expense: return .red
        }
    }
    
    var transactionTypeValue: Int? {
        switch self {
        case .all: return nil
        case .income: return 1
        case .expense: return 2
        }
    }
}

// MARK: - Transaction Filter View

struct TransactionFilterView: View {
    @Binding var selectedFilter: TransactionFilterType
    var onFilterChanged: ((TransactionFilterType) -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionFilterType.allCases, id: \.self) { filterType in
                    FilterChip(
                        title: filterType.rawValue,
                        isSelected: selectedFilter == filterType,
                        selectedColor: filterType.color
                    ) {
                        selectedFilter = filterType
                        onFilterChanged?(filterType)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TransactionFilterView(selectedFilter: .constant(.all))
        TransactionFilterView(selectedFilter: .constant(.income))
        TransactionFilterView(selectedFilter: .constant(.expense))
        
        HStack {
            FilterChip(title: "All", isSelected: true, selectedColor: .blue) {}
            FilterChip(title: "Income", isSelected: false, selectedColor: .green) {}
            FilterChip(title: "Expense", isSelected: false, selectedColor: .red) {}
        }
    }
}
