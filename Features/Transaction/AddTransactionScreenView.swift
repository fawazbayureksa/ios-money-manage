//
//  AddTransactionScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//
import SwiftUI
struct AddTransactionScreenView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Text("Add Transaction Form")
                .navigationTitle("Add Transaction")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
