//
//  HeaderView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 17/01/26.
//

import SwiftUI

struct HeaderView: View {
    let username: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // LEFT - Welcome text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(username)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.5)
                    
                    Text("Let's manage your finances today 💰")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                }
                
                Spacer()
                
                // RIGHT - Profile Button
                Button(action: {
                    print("Avatar tapped")
                }) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 52, height: 52)
                        
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer(minLength: 0)
        }
        .padding(.top, UIApplication.shared.safeAreaTop + 16)
        .padding(.bottom, 32)
        .background(
            ZStack {
                // Base Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.42, blue: 0.47), // #1f6a79
                        Color(red: 0.08, green: 0.32, blue: 0.36)  // Darker shade
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Decorative Elements
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                            .offset(x: geo.size.width * 0.7, y: -geo.size.height * 0.2)
                        
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .blur(radius: 30)
                            .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.5)
                    }
                }
            }
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
        .shadow(color: Color(red: 0.12, green: 0.42, blue: 0.47).opacity(0.3),
                radius: 12,
                x: 0,
                y: 8)
        .padding(.bottom, 20)
    }
}
