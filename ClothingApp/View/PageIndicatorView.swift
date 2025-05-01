//
//  PageIndicatorView.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        Text("\(currentPage)/\(totalPages)")
            .font(.caption2)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())
    }
}
