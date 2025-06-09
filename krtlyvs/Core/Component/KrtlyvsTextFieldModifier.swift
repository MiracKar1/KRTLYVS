//
//  KrtlyvsTextFieldModifier.swift
//  krtlyvs
//
//  Created by Mirac Kar on 3.05.2025.
//

import SwiftUI

struct KrtlyvsTextFieldModifier: ViewModifier {
    func body(content: Content)-> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 24)
    }
}
