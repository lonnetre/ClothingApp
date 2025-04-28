//
//  CustomToolbar.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct HomeToolbar: View {
    let temperature: String
    let onCreateOutfit: () -> Void
    let onSwapOutfits: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onSwapOutfits) {
                VStack {
                    Image(systemName: "shuffle")
                }
            }
            
            Divider()
                .frame(height: 20)
            
            Button(action: onCreateOutfit) {
                HStack {
                    Image(systemName: "rectangle.dashed")
                    Text("Create an outfit")
                        .font(.footnote)
                }
            }
            
            Divider()
                .frame(height: 20)
            
            HStack {
                Image(systemName: "cloud.sun.fill")
                Text(temperature)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.systemGray5)),
            alignment: .top
        )
    }
}
