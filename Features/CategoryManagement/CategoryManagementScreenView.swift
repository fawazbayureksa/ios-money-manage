//
//  CategoryManagementScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 04/02/26.
//

import SwiftUI

struct CategoryManagementScreenView: View {
    @StateObject private var viewModel = CategoryManagementViewModel()
    @State private var showAddCategory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.gray.opacity(0.1))
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("Loading categories...")
                        .scaleEffect(1.2)
                } else if viewModel.categories.isEmpty {
                    EmptyStateView()
                } else {
                    CategoryListContent(viewModel: viewModel)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchCategories()
            }
            .alert("Delete Category", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.categoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteCategory()
                    }
                }
            } message: {
                if let category = viewModel.categoryToDelete {
                    Text("Are you sure you want to delete \"\(category.categoryName)\"?")
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryScreenView(onSuccess: {
                    showAddCategory = false
                    Task {
                        await viewModel.fetchCategories()
                    }
                })
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}

private struct CategoryListContent: View {
    @ObservedObject var viewModel: CategoryManagementViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.categories) { category in
                    CategoryCard(category: category) {
                        viewModel.confirmDelete(category: category)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                
                Text(String(category.categoryName.prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.categoryName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(category.description.isEmpty ? "No description" : category.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Categories")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Tap the + button to create your first category")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    CategoryManagementScreenView()
}
