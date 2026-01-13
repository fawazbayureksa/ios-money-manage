//
//  HomeScreenView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 13/01/26.
//
import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Welcome to \(AppConfig.appName)")
                    .font(.system(size: 14, weight: .bold))

            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    HomeScreenView()
}
