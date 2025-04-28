//
//  CustomTabbar.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct HomeTabBar: View {
    @Binding var selectedIndex: Int
    
    let tabItems = [
        TabItem(icon: "person.fill", title: "Today"),
        TabItem(icon: "plus.circle", title: "Add clothes"),
        TabItem(icon: "leaf.fill", title: "Sustainability"),
        TabItem(icon: "cabinet.fill", title: "Closet")
    ]
    
    var body: some View {
        HStack {
            ForEach(0..<tabItems.count, id: \.self) { index in
                Button(action: {
                    selectedIndex = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabItems[index].icon)
                            .foregroundColor(selectedIndex == index ? .blue : .gray)
                        
                        Text(tabItems[index].title)
                            .font(.caption2)
                            .foregroundColor(selectedIndex == index ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 15)
        .background(Color(UIColor.systemBackground))
    }
}

struct TabItem {
    let icon: String
    let title: String
}
