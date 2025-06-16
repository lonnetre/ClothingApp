//
//  ClothingItemView.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct ClothingItemView: View {
    let item: ClothingItem
    let isSelected: Bool
    let height: CFloat
    let onTap: () -> Void
    
    var body: some View {
        if let uiImage = item.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: CGFloat(height))
        } else {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: CGFloat(height))
        }
    }
}
