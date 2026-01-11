//
//  LoginView.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 11/01/26.
//

import SwiftUI
import Foundation

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)

            Button("Login") {
                viewModel.login()
            }
        }
        .padding()
    }
}
