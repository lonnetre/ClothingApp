//
//  ContentView.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

// ContentView.swift (App Entry Point)
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddClothesPopover = false
    @State private var presentPopup = false
    
    // Define tab items
    let tabs = [
        ("Today", "person.fill"),
        ("Add clothes", "plus.circle"),
        ("Sustainability", "leaf.fill"),
        ("Closet", "cabinet.fill")
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if selectedTab == 0 {
                    TodayView()
                } else if selectedTab == 2 {
                    SustainabilityView()
                } else {
                    // ClosetView()
                }
            }
            
            // Add Clothes View
            .popover(isPresented: $showAddClothesPopover) {
                AddClothesView(presentMe: $presentPopup)
                    .font(.footnote)
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // stays always on the bottom
            .edgesIgnoringSafeArea(.bottom)
            
            // Custom tab bar
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        if index == 1 { // Add Clothes tab
                            showAddClothesPopover = true
                        } else {
                            selectedTab = index
                        }
                    }) {
                        VStack {
                            ZStack {
                                Image(systemName: tabs[index].1)
                                    .font(.system(size: 24))
                            }
                            .frame(height: 30)
                            
                            Text(tabs[index].0)
                                .font(.caption2)
                        }
                        .foregroundStyle(getTabColor(index: index))
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
