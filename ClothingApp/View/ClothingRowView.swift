//
//  ClothingRowView.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct ClothingRowView: View {
    let categoryPage: ClothingPage
    let onSelectItem: (Int) -> Void
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    var body: some View {
        
        let rowHeight = categoryPage.items.first?.category.preferredHeight ?? 100
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // go though all of the parts of clothes
                ForEach(0..<categoryPage.items.count, id: \.self) {index in
                    ClothingItemView (item: categoryPage.items[index], isSelected: categoryPage.selectedItemIndex == index, height: CFloat(rowHeight), onTap: {onSelectItem(index)})
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Swiped left
                            onSwipeLeft()
                        } else {
                            // Swiped right
                            onSwipeRight()
                        }
                    }
            )
            
            // Page indicator positioned at the bottom left corner INSIDE the background
            .overlay(
                PageIndicatorView(
                    currentPage: categoryPage.currentPage,
                    totalPages: categoryPage.totalPages
                ),
                alignment: .bottomLeading
            )
            .padding(.leading, 12)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < 0 {
                        // Swiped left
                        onSwipeLeft()
                    } else {
                        // Swiped right
                        onSwipeRight()
                    }
                }
        )
    }
}
