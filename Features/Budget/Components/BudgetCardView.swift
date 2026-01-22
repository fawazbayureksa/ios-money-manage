//
//  BudgetCardView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 22/01/26.
//

import SwiftUI

struct BudgetCardView: View {
    let budget: Budget
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: statusIcon)
                            .foregroundColor(statusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(budget.category_name ?? "General")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(budget.period.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(statusText)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(budget.formattedSpent) / \(budget.formattedAmount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: min(budget.percentage_used ?? 0, 100), total: 100)
                        .tint(statusColor)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    HStack {
                        Text("\(Int(budget.percentage_used ?? 0))% used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let remaining = budget.remaining_amount {
                            Text(remaining >= 0 ? "\(formattedRemaining) left" : "\(formattedOverContent) over")
                                .font(.caption)
                                .foregroundColor(remaining >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch budget.status {
        case "safe": return .green
        case "warning": return .orange
        case "exceeded": return .red
        default: return .blue
        }
    }
    
    private var statusIcon: String {
        switch budget.status {
        case "safe": return "checkmark.circle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "exceeded": return "xmark.octagon.fill"
        default: return "info.circle.fill"
        }
    }
    
    private var statusText: String {
        budget.status?.uppercased() ?? "INFO"
    }
    
    private var formattedRemaining: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: NSNumber(value: abs(budget.remaining_amount ?? 0))) ?? "Rp0"
    }

    private var formattedOverContent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: NSNumber(value: abs(budget.remaining_amount ?? 0))) ?? "Rp0"
    }
}

struct BudgetCardView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetCardView(budget: Budget.mockData[0], onTap: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
