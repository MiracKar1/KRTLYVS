//
//  UserStatView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 12.03.2025.
//

import SwiftUI

struct UserStatView: View {
    let value : Int
    let title : String
    var body: some View {
        VStack{
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(title)
                .font(.subheadline)
        }
    }
}

//#Preview {
//    UserStatView(value: 1, title: "Gönderiler")
//}
