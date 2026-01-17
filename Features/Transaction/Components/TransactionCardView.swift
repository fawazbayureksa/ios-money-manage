//
//  TransactionCardView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct TransactionCardView: View {
    let transaction: Transaction
    var onDelete: (() -> Void)?
    
    private var typeColor: Color {
        transaction.isIncome ? .green : .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                // Type Indicator & Amount
                HStack(spacing: 12) {
                    TransactionTypeIcon(isIncome: transaction.isIncome, color: typeColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(transaction.isIncome ? "+" : "-") \(formatCurrency(transaction.amount))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(typeColor)
                        
                        Text(transaction.categoryName ?? "No Category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Delete Button
                Button(action: { onDelete?() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            
            // Chips Row
            HStack(spacing: 8) {
                if let bankName = transaction.bankName {
                    ChipView(icon: "building.columns", text: bankName)
                }
                
                ChipView(icon: "calendar", text: formatDateShort(transaction.date))
            }
            
            // Description
            if let description = transaction.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
    
    private func formatDateShort(_ dateString: String) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Try multiple input formats
        let inputFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",  // ISO 8601 with milliseconds
            "yyyy-MM-dd'T'HH:mm:ssZ",       // ISO 8601
            "yyyy-MM-dd'T'HH:mm:ss",        // ISO 8601 without timezone
            "yyyy-MM-dd HH:mm:ss",          // DateTime with space
            "yyyy-MM-dd"                     // Date only
        ]
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in inputFormats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: dateString) {
                return outputFormatter.string(from: date)
            }
        }
        
        // Try ISO8601DateFormatter as fallback
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - Transaction Type Icon

struct TransactionTypeIcon: View {
    let isIncome: Bool
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
            
            Image(systemName: isIncome ? "arrow.up" : "arrow.down")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Chip View

struct ChipView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .foregroundColor(.secondary)
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        TransactionCardView(transaction: Transaction.mockData[0])
        TransactionCardView(transaction: Transaction.mockData[1])
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
