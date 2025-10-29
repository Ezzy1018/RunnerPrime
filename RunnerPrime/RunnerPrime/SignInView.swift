//
//  SignInView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Sign in")
                .font(.title)
                .foregroundColor(.rpWhiteLiteral)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Signed in: \(authResults)")
                case .failure(let error):
                    print("Sign in error: \(error)")
                }
            }
            .frame(height: 45)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .background(Color.rpEerieBlackLiteral.edgesIgnoringSafeArea(.all))
    }
}
