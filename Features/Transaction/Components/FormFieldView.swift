//
//  FormFieldView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct FormSectionHeader: View {
    let title: String
    var isRequired: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if isRequired {
                Text("*")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
    }
}

struct FormErrorText: View {
    let error: String?
    
    var body: some View {
        if let error = error, !error.isEmpty {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                Text(error)
                    .font(.caption)
                Spacer()
            }
            .foregroundColor(.red)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

struct AmountInputField: View {
    @Binding var amount: String
    var error: String?
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormSectionHeader(title: "Amount", isRequired: true)
            
            HStack(spacing: 12) {
                Text("Rp")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $amount)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .disabled(isDisabled)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(error != nil ? Color.red : Color.clear, lineWidth: 2)
            )
            
            FormErrorText(error: error)
        }
    }
}

struct DatePickerField: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormSectionHeader(title: "Date")
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                    .font(.title3)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

struct DescriptionInputField: View {
    @Binding var text: String
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormSectionHeader(title: "Description")
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                TextField("Add notes about this transaction", text: $text, axis: .vertical)
                    .lineLimit(3...5)
                    .disabled(isDisabled)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        AmountInputField(amount: .constant("150000"), error: nil)
        AmountInputField(amount: .constant(""), error: "Amount is required")
        DatePickerField(date: .constant(Date()))
        DescriptionInputField(text: .constant(""))
    }
    .padding()
}
