//
//  HomeScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 13/01/26.
//
import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        NavigationView{
            ScrollView {
                HeaderView(username: "Fawwaz Bayureksa")
            }
            .ignoresSafeArea(edges: .top)
        }.navigationTitle("Home")
    }
}

#Preview {
    HomeScreenView()
}
