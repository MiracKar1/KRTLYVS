//
//  SecureFieldWithButton.swift
//  krtlyvs
//
//  Created by Mirac Kar on 10.05.2025.
//

import SwiftUI

struct SecureFieldWithButton: View {
    let title: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        HStack {
            if isSecure {
                    SecureField(title, text: $text)
            } else {
                    TextField(title, text: $text)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            }
        .modifier(KrtlyvsTextFieldModifier())
    }
}

//#Preview {
//    SecureFieldWithButton("Password", //text: .constant(""))
//}
