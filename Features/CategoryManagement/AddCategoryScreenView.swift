//
//  AddCategoryScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 04/02/26.
//

import SwiftUI

struct AddCategoryScreenView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddCategoryViewModel()
    let onSuccess: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.gray.opacity(0.1))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Form {
                        Section(header: Text("Category Details").font(.headline)) {
                            TextField("Category Name", text: $viewModel.categoryName)
                                .textInputAutocapitalization(.words)
                            
                            TextField("Description (Optional)", text: $viewModel.categoryDescription, axis: .vertical)
                                .lineLimit(3...6)
                            
                            if viewModel.categoryDescription.count > 0 {
                                HStack {
                                    Spacer()
                                    Text("\(viewModel.categoryDescription.count)/200")
                                        .font(.caption)
                                        .foregroundColor(viewModel.categoryDescription.count > 200 ? .red : .secondary)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                if await viewModel.createCategory() {
                                    onSuccess()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Text("Create Category")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: viewModel.isValid ? [.blue, .purple] : [.gray.opacity(0.5), .gray.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        .padding(.horizontal, 16)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    viewModel.showAlert = false
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    AddCategoryScreenView(onSuccess: {})
}
