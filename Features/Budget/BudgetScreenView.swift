import SwiftUI

struct BudgetScreenView: View {
    @StateObject private var viewModel = BudgetListViewModel()
    @State private var showingAddBudget = false
    @State private var selectedBudget: Budget?
    @State private var showTransactions = false
    
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
                                    handleBudgetPress(budget: budget)
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
            .navigationDestination(isPresented: $showTransactions) {
                if let budget = selectedBudget {
                    TransactionsForBudgetView(budget: budget)
                }
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
    
    // MARK: - Handle Budget Press
    
    private func handleBudgetPress(budget: Budget) {
        selectedBudget = budget
        showTransactions = true
    }
}

// MARK: - Transactions for Budget View

struct TransactionsForBudgetView: View {
    let budget: Budget
    
    @StateObject private var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var hasInitialized = false
    
    init(budget: Budget) {
        self.budget = budget
        self._viewModel = StateObject(wrappedValue: TransactionViewModel())
    }
    
    // MARK: - Date Range
    
    private var dateRange: (startDate: Date, endDate: Date) {
        let now = Date()
        let calendar = Calendar.current
        
        if budget.period == "monthly" {
            // Start of current month
            let startComponents = calendar.dateComponents([.year, .month], from: now)
            let startDate = calendar.date(from: startComponents) ?? now
            
            // End of current month
            var endComponents = DateComponents()
            endComponents.year = calendar.component(.year, from: now)
            endComponents.month = calendar.component(.month, from: now)
            endComponents.day = calendar.range(of: .day, in: .month, for: now)?.count ?? 31
            let endDate = calendar.date(from: endComponents) ?? now
            
            return (startDate, endDate)
        } else {
            // Yearly: Start of current year
            var startComponents = DateComponents()
            startComponents.year = calendar.component(.year, from: now)
            startComponents.month = 1
            startComponents.day = 1
            let startDate = calendar.date(from: startComponents) ?? now
            
            // End of current year
            var endComponents = DateComponents()
            endComponents.year = calendar.component(.year, from: now)
            endComponents.month = 12
            endComponents.day = 31
            let endDate = calendar.date(from: endComponents) ?? now
            
            return (startDate, endDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Header
            FilterHeaderView(
                categoryName: budget.categoryName ?? "Category",
                startDate: dateRange.startDate,
                endDate: dateRange.endDate,
                onDismiss: { dismiss() }
            )
            
            // Transaction List
            if viewModel.isLoading && viewModel.transactions.isEmpty {
                ProgressView("Loading transactions...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.transactions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No Transactions Found")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("No transactions for this budget period.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionCardView(
                                transaction: transaction,
                                onDelete: nil,
                                onUpdate: nil
                            )
                        }
                        
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading more...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                        }
                        
                        if viewModel.hasMore {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    viewModel.loadMoreTransactions()
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    viewModel.refreshTransactions()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            // Use onAppear with proper sequencing
            guard !hasInitialized else { return }
            
            print("🔧 Setting filters - CategoryId: \(budget.categoryId), Type: expense")
            print("🔧 Date range: \(dateRange.startDate) to \(dateRange.endDate)")
            
            // Set filters first
            viewModel.filterType = .expense
            viewModel.categoryId = budget.categoryId
            viewModel.startDate = dateRange.startDate
            viewModel.endDate = dateRange.endDate
            
            hasInitialized = true
            
            // Fetch after a brief moment to ensure all @Published values are set
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("🚀 Calling fetchTransactions with filters set")
                viewModel.fetchTransactions(reset: true)
            }
        }
    }
}

// MARK: - Filter Header View

private struct FilterHeaderView: View {
    let categoryName: String
    let startDate: Date
    let endDate: Date
    let onDismiss: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Bar
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Budget Transactions")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Color.clear
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Category Badge
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .foregroundColor(.purple)
                Text(categoryName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(20)
            
            // Date Range
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
        }
        .background(Color(.systemBackground))
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
