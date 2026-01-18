//
//  SelectableChipGroup.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct SelectableChipGroup<T: Identifiable>: View {
    let items: [T]
    let selectedItem: T?
    let titleKeyPath: KeyPath<T, String>
    let onSelect: (T) -> Void
    var useFlexibleLayout: Bool = false
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 80, maximum: 150), spacing: 10)
    ]
    
    var body: some View {
        if useFlexibleLayout {
            // Flexible flow layout - shows full text without truncation
            FlowLayout(spacing: 10) {
                ForEach(items) { item in
                    SelectableChip(
                        title: item[keyPath: titleKeyPath],
                        isSelected: selectedItem?.id as? Int == item.id as? Int,
                        truncate: false,
                        action: { onSelect(item) }
                    )
                }
            }
        } else {
            // Grid layout
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(items) { item in
                    SelectableChip(
                        title: item[keyPath: titleKeyPath],
                        isSelected: selectedItem?.id as? Int == item.id as? Int,
                        truncate: true,
                        action: { onSelect(item) }
                    )
                }
            }
        }
    }
}

// MARK: - Flow Layout for flexible chip sizing

struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                
                self.size.width = max(self.size.width, currentX - spacing)
            }
            
            self.size.height = currentY + lineHeight
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    var truncate: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .lineLimit(truncate ? 1 : nil)
                .fixedSize(horizontal: !truncate, vertical: false)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: truncate ? .infinity : nil)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    VStack(spacing: 20) {
        SelectableChipGroup(
            items: Category.mockData,
            selectedItem: Category.mockData[0],
            titleKeyPath: \.categoryName,
            onSelect: { _ in }
        )
        
        SelectableChipGroup(
            items: Bank.mockData,
            selectedItem: nil,
            titleKeyPath: \.bankName,
            onSelect: { _ in }
        )
    }
    .padding()
}
