//
//  ContentView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 10/01/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            VStack(spacing: 8) {
                Text("App: \(AppConfig.appName)")
                    .font(.caption)
                Text("API: \(AppConfig.apiBaseURL)")
                    .font(.caption)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
