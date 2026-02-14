//
//  AdvancedFilterView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 14/02/26.
//

import SwiftUI

struct AdvancedFilterView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: TransactionViewModel
    
    @State private var selectedCategoryId: Int?
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Category Filter Section
                Section(header: Text("Category")) {
                    if viewModel.isCategoriesLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Picker("Select Category", selection: $selectedCategoryId) {
                            Text("All Categories").tag(nil as Int?)
                            ForEach(viewModel.categories) { category in
                                Text(category.categoryName).tag(category.id as Int?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // MARK: - Date Range Section
                Section(header: Text("Date Range")) {
                    // Start Date
                    HStack {
                        Text("From")
                        Spacer()
                        if let start = startDate {
                            Button(dateFormatter.string(from: start)) {
                                showStartDatePicker.toggle()
                            }
                            .foregroundColor(.blue)
                            
                            Button {
                                startDate = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button("Select Date") {
                                showStartDatePicker.toggle()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if showStartDatePicker {
                        DatePicker(
                            "Start Date",
                            selection: Binding(
                                get: { startDate ?? Date() },
                                set: { startDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: startDate) { _, _ in
                            showStartDatePicker = false
                        }
                    }
                    
                    // End Date
                    HStack {
                        Text("To")
                        Spacer()
                        if let end = endDate {
                            Button(dateFormatter.string(from: end)) {
                                showEndDatePicker.toggle()
                            }
                            .foregroundColor(.blue)
                            
                            Button {
                                endDate = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button("Select Date") {
                                showEndDatePicker.toggle()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if showEndDatePicker {
                        DatePicker(
                            "End Date",
                            selection: Binding(
                                get: { endDate ?? Date() },
                                set: { endDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: endDate) { _, _ in
                            showEndDatePicker = false
                        }
                    }
                }
                
                // MARK: - Quick Date Presets
                Section(header: Text("Quick Presets")) {
                    Button("Today") {
                        let today = Calendar.current.startOfDay(for: Date())
                        startDate = today
                        endDate = today
                    }
                    
                    Button("This Week") {
                        let calendar = Calendar.current
                        let today = Date()
                        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))
                        startDate = weekStart
                        endDate = today
                    }
                    
                    Button("This Month") {
                        let calendar = Calendar.current
                        let today = Date()
                        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
                        startDate = monthStart
                        endDate = today
                    }
                    
                    Button("Last 30 Days") {
                        let today = Date()
                        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)
                        startDate = thirtyDaysAgo
                        endDate = today
                    }
                }
                
                // MARK: - Clear Filters
                if selectedCategoryId != nil || startDate != nil || endDate != nil {
                    Section {
                        Button("Clear All Filters", role: .destructive) {
                            selectedCategoryId = nil
                            startDate = nil
                            endDate = nil
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applyFilters(
                            categoryId: selectedCategoryId,
                            startDate: startDate,
                            endDate: endDate
                        )
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Initialize with current filter values
                selectedCategoryId = viewModel.categoryId
                startDate = viewModel.startDate
                endDate = viewModel.endDate
                
                // Fetch categories if not already loaded
                if viewModel.categories.isEmpty {
                    viewModel.fetchCategories()
                }
            }
        }
    }
}

// MARK: - Filter Badge View
struct FilterBadgeView: View {
    let hasActiveFilters: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .imageScale(.medium)
                if hasActiveFilters {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

// MARK: - Active Filter Chips View
struct ActiveFilterChipsView: View {
    @ObservedObject var viewModel: TransactionViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    var body: some View {
        if viewModel.hasActiveAdvancedFilters {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Category chip
                    if let categoryId = viewModel.categoryId,
                       let category = viewModel.categories.first(where: { $0.id == categoryId }) {
                        ActiveFilterChip(
                            title: category.categoryName,
                            onRemove: {
                                viewModel.categoryId = nil
                                viewModel.fetchTransactions(reset: true)
                            }
                        )
                    }
                    
                    // Date range chip
                    if viewModel.startDate != nil || viewModel.endDate != nil {
                        ActiveFilterChip(
                            title: dateRangeText,
                            onRemove: {
                                viewModel.startDate = nil
                                viewModel.endDate = nil
                                viewModel.fetchTransactions(reset: true)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }
    
    private var dateRangeText: String {
        if let start = viewModel.startDate, let end = viewModel.endDate {
            return "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))"
        } else if let start = viewModel.startDate {
            return "From \(dateFormatter.string(from: start))"
        } else if let end = viewModel.endDate {
            return "Until \(dateFormatter.string(from: end))"
        }
        return ""
    }
}

// MARK: - Active Filter Chip
struct ActiveFilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

#Preview {
    AdvancedFilterView(
        isPresented: .constant(true),
        viewModel: TransactionViewModel()
    )
}
