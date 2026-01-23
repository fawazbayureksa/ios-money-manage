//
//  AddBudgetScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 23/01/26.
//
import SwiftUI

struct AddBudgetScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddBudgetViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoadingData {
                    LoadingDataView()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header Card
                            HeaderCard()
                            
                            // Form Content
                            FormContent(viewModel: viewModel)
                            
                            // Action Buttons
                            ActionButtons(
                                isLoading: viewModel.isLoading,
                                onCancel: { dismiss() },
                                onSubmit: { Task { await viewModel.submitBudget() } }
                            )
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Budget created successfully!")
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                // Use mock data for now, replace with loadData() when API is ready
                // viewModel.loadMockData()
                viewModel.loadData()
            }
        }
    }
}

// MARK: - Loading View

private struct LoadingDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Header Card

private struct HeaderCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "banknote.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Create Budget")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Set spending limits for your categories")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Form Content

private struct FormContent: View {
    @ObservedObject var viewModel: AddBudgetViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Amount
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Budget Amount", isRequired: true)
                
                HStack(spacing: 12) {
                    Text("Rp")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $viewModel.amount)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .disabled(viewModel.isLoading)
                        .onChange(of: viewModel.amount) { _, _ in
                            viewModel.amountError = nil
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.amount)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(viewModel.amountError != nil ? Color.red : Color.clear, lineWidth: 2)
                        )
                )
                .shadow(color: viewModel.amountError != nil ? Color.red.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 2)
                
                FormErrorText(error: viewModel.amountError)
                
                // Quick amount suggestions
                if viewModel.amount.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach([500000, 1000000, 2000000, 5000000], id: \.self) { amount in
                                QuickAmountButton(amount: amount) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.amount = String(amount)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
            
            // Category
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Category", isRequired: true)
                
                if viewModel.categories.isEmpty {
                    EmptyStateChip(text: "No categories available")
                } else {
                    SelectableChipGroup(
                        items: viewModel.categories,
                        selectedItem: viewModel.selectedCategory,
                        titleKeyPath: \.categoryName,
                        onSelect: { category in
                            viewModel.selectedCategory = category
                            viewModel.categoryError = nil
                        },
                        useFlexibleLayout: true
                    )
                }
                
                FormErrorText(error: viewModel.categoryError)
            }
            
            // Period Selector
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Budget Period")
                
                HStack(spacing: 12) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { period in
                        PeriodButton(
                            period: period,
                            isSelected: viewModel.selectedPeriod == period,
                            action: { viewModel.selectedPeriod = period }
                        )
                    }
                }
            }
            
            // Start Date
            DatePickerField(date: $viewModel.startDate)
            
            // Alert Threshold Slider
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Alert Threshold: \(viewModel.alertThreshold)%")
                
                HStack(spacing: 16) {
                    Text("50%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .leading)
                    
                    Slider(value: Binding(
                        get: { Double(viewModel.alertThreshold) },
                        set: { viewModel.alertThreshold = Int($0) }
                    ), in: 50...100, step: 5)
                    .accentColor(.purple)
                    
                    Text("100%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
                
                Text("Get notified when you reach this percentage of your budget")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Budget Preview Card
            BudgetPreviewCard(
                amount: viewModel.amount,
                period: viewModel.selectedPeriod.displayName,
                category: viewModel.selectedCategory?.categoryName,
                alertThreshold: viewModel.alertThreshold
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

// MARK: - Period Button

private struct PeriodButton: View {
    let period: BudgetPeriod
    let isSelected: Bool
    let action: () -> Void
    
    private var icon: String {
        period == .monthly ? "calendar" : "calendar.circle.fill"
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(period.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Quick Amount Button

private struct QuickAmountButton: View {
    let amount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(formatAmount())
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.1), .blue.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .foregroundColor(.purple)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Budget Preview Card

private struct BudgetPreviewCard: View {
    let amount: String
    let period: String
    let category: String?
    let alertThreshold: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Budget Preview")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .foregroundColor(.purple)
            }
            
            Divider()
            
            VStack(spacing: 12) {
                PreviewRow(label: "Amount", value: formatAmount())
                PreviewRow(label: "Category", value: category ?? "Not selected")
                PreviewRow(label: "Period", value: period)
                PreviewRow(label: "Alert at", value: "\(alertThreshold)%")
            }
            
            // Visual indicator for alert threshold
            if !amount.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Alert Level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(0..<10) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(thresholdColor(for: index))
                                .frame(maxWidth: .infinity)
                                .frame(height: 6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.1), .blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.3), value: alertThreshold)
    }
    
    private func formatAmount() -> String {
        let value = Double(amount) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp0"
    }
    
    private func thresholdColor(for index: Int) -> Color {
        let percentage = (index + 1) * 10
        if percentage <= alertThreshold {
            return .purple.opacity(0.8)
        } else {
            return .gray.opacity(0.2)
        }
    }
}

private struct PreviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Action Buttons

private struct ActionButtons: View {
    let isLoading: Bool
    let onCancel: () -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Cancel Button
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                    )
                    .foregroundColor(.primary)
            }
            .disabled(isLoading)
            
            // Submit Button
            Button(action: onSubmit) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Create")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
}

// MARK: - Preview

#Preview {
    AddBudgetScreenView()
}
