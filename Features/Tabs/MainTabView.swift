//
//  MainTabView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 18/01/26.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var showAddTransaction = false
    
    var body: some View {
        TabView {
            HomeScreenView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            TransactionScreenView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Transactions")
                }
            BudgetScreenView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Budget")
                }
            ProfileScreenView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color(red: 31/255, green: 106/255, blue: 121/255)) //teal
        .safeAreaInset(edge: .bottom) {
            floatingButton
        }.sheet(isPresented: $showAddTransaction) {
            AddTransactionScreenView()
        }

    }
    private var floatingButton: some View {
        Button {
            showAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color(red: 31/255, green: 106/255, blue: 121/255))
                .clipShape(Circle())
                .shadow(radius: 6)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthState())
}
