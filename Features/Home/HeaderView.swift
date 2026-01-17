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
        VStack {
            HStack(alignment: .top) {
                // LEFT - Welcome text
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .tracking(0.5)
                    Text(username)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Let's manage your finances today 💰")
                           .font(.system(size: 15))
                           .foregroundColor(.white.opacity(0.9))
                }.padding(.trailing, 12)
                
                Spacer()
                Button(action: {
                    print("Avatar tapped")
                   }) {
                       Image(systemName: "person.circle.fill")
                           .resizable()
                           .frame(width: 48, height: 48)
                           .foregroundColor(.white)
                   }
            } .padding(.horizontal, 20)
                .padding(.top, 12)
                Spacer(minLength: 0)
        }
        .padding(.top, UIApplication.shared.safeAreaTop + 16)
                .padding(.bottom, 24)
                .background(
                    Color(red: 0.12, green: 0.42, blue: 0.47) // #1f6a79
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .shadow(color: .black.opacity(0.15),
                        radius: 8,
                        x: 0,
                        y: 4)
                .padding(.bottom, 20)
    }
}
