//
//  OptionButton.swift
//  ClothingApp
//
//  Created by yehor on 16.06.25.
//

import SwiftUI

struct OptionButton: View {
    let icon: String
    let label: String
    let width: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(.label))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, height: 70)
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}
