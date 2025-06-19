//
//  CustomPill.swift
//  ClothingApp
//
//  Created by yehor on 19.06.25.
//

import SwiftUI

struct CustomPill: View {
    let icon: String
    let label: String

    var body: some View {
        Label(label, systemImage: icon)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(UIColor.systemGray5))
            .clipShape(Rectangle())
            .cornerRadius(8)
    }
}
