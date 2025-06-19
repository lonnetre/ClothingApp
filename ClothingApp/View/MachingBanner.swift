//
//  MachingBanner.swift
//  ClothingApp
//
//  Created by yehor on 19.06.25.
//

import SwiftUI

struct MatchingBanner: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGray5)
                .frame(height: 90)
                .ignoresSafeArea(edges: .horizontal)

            VStack(spacing: 4) {
                Text("Add these matching clothes to your")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Text("scanned item with")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}
