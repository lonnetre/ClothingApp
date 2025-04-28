//
//  HomeTabBar.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct HomeTabBar: View {
    @State private var selectedTab = 0
    
    // Define tab items
    let tabs = [
        ("Today", "person.fill"),
        ("Add clothes", "plus.circle"),
        ("Sustainability", "leaf.fill"),
        ("Closet", "cabinet.fill")
    ]
    
    var body: some View {
        VStack {
            
            ZStack {
                if selectedTab == 0 {
                    // TodayView()
                } else if selectedTab == 1 {
                    // AddClothesView
                } else if selectedTab == 2 {
                    // SustainabilityView()
                } else {
                    // ClosetView()
                }
            }
            
            // Custom tab bar
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {selectedTab = index}) {
                        VStack {
                            ZStack {
                                Image(systemName: tabs[index].1)
                                    .font(.system(size: 24))
                            }
                            .frame(height: 30)
                            
                            Text(tabs[index].0)
                                .font(.caption2)
                        }
                        .foregroundColor(getTabColor(index: index))
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 0)
            .frame(height: 60)
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: -2)
        }
    }
    
    // Helper function to determine tab color
    private func getTabColor(index: Int) -> Color {
        if index == selectedTab {
            return .blue
        } else if index == 2 {  // Sustainability tab (index 2)
            return .green
        } else {
            return .gray
        }
    }
}

