//
//  TodayView.swift
//  ClothingApp
//
//  Created by yehor on 28.04.25.
//

import SwiftUI

// ContentView.swift (App Entry Point)
struct TodayView: View {
    @StateObject private var viewModel = OutfitBuilderViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(ClothingCategory.allCases, id: \.self) { category in
                        if let page = viewModel.clothingPages[category] {
                            ClothingRowView(
                                categoryPage: page,
                                onSelectItem: { index in
                                    viewModel.selectItem(category: category, index: index)
                                },
                                onSwipeLeft: {
                                    viewModel.nextPage(for: category)
                                },
                                onSwipeRight: {
                                    viewModel.previousPage(for: category)
                                }
                            )
                        }
                    }
                }
            }
            
            // Bottom toolbar
            TodayToolBar(
                temperature: viewModel.weatherTemperature,
                onCreateOutfit: viewModel.createOutfit,
                onSwapOutfits: viewModel.swapOutfits
            )
        }
    }
}
