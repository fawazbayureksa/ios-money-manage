//
//  AddTransactionScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//
import SwiftUI

struct AddTransactionScreenView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddTransactionViewModel()
    
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
                                onSubmit: { viewModel.submitTransaction() }
                            )
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Add Transaction")
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
                Text("Transaction created successfully!")
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
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Record Transaction")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Track your income or expense")
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
    @ObservedObject var viewModel: AddTransactionViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Transaction Type
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Transaction Type")
                TransactionTypeSelector(selectedType: $viewModel.transactionType)
            }
            
            // Amount
            AmountInputField(
                amount: $viewModel.amount,
                error: viewModel.amountError,
                isDisabled: viewModel.isLoading
            )
            .onChange(of: viewModel.amount) { _, _ in
                viewModel.amountError = nil
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
                        }
                    )
                }
                
                FormErrorText(error: viewModel.categoryError)
            }
            
            // Bank
            VStack(alignment: .leading, spacing: 12) {
                FormSectionHeader(title: "Bank Account", isRequired: true)
                
                if viewModel.banks.isEmpty {
                    EmptyStateChip(text: "No banks available")
                } else {
                    SelectableChipGroup(
                        items: viewModel.banks,
                        selectedItem: viewModel.selectedBank,
                        titleKeyPath: \.bankName,
                        onSelect: { bank in
                            viewModel.selectedBank = bank
                            viewModel.bankError = nil
                        },
                        useFlexibleLayout: true
                    )
                }
                
                FormErrorText(error: viewModel.bankError)
            }
            
            // Date
            DatePickerField(date: $viewModel.date)
            
            // Description
            DescriptionInputField(
                text: $viewModel.description,
                isDisabled: viewModel.isLoading
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

// MARK: - Empty State Chip

private struct EmptyStateChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.secondary.opacity(0.5))
                    )
            )
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
                                colors: [.blue, .purple],
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
    AddTransactionScreenView()
}
