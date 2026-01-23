import SwiftUI

struct BudgetScreenView: View {
    @StateObject private var viewModel = BudgetListViewModel()
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.budgets.isEmpty {
                    ProgressView("Loading Budgets...")
                } else if viewModel.budgets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "banknote")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Budgets Found")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Start by adding a new budget for your categories.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { showingAddBudget = true }) {
                            Text("Add Budget")
                                .fontWeight(.semibold)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.budgets) { budget in
                                BudgetCardView(budget: budget) {
                                    // Handle navigation to transaction detail with filter
                                    print("Navigating to transactions for \(budget.categoryName ?? "")")
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddBudget = true }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Budgets")
            .task {
                await viewModel.fetchBudgets()
            }
            .alert("Error", isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {}
                Button("Retry") {
                    Task {
                        await viewModel.fetchBudgets()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetScreenView()
                    .onDisappear {
                        Task {
                            await viewModel.refresh()
                        }
                    }
            }
        }
    }
}

struct BudgetScreenView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetScreenView()
    }
}


#Preview {
    BudgetScreenView()
}
