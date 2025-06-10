//
//  CustomToolbar.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct TodayToolBar: View {
    let temperature: String
    let onCreateOutfit: () -> Void
    let onSwapOutfits: () -> Void
    
    // TODO: custom design of a toolBar
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onSwapOutfits) {
                Image("custom.shuffle.badge.sparkles")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue, .gray)
            }
            
            Divider()
                .frame(height: 20)
            
            Button(action: onCreateOutfit) {
                HStack {
                    Image("custom.cabinet.fill.badge.plus")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .gray)
                    Text("Create an outfit")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            
            Divider()
                .frame(height: 20)
            
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(Color(.systemGray))
                Text(temperature)
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(UIColor.systemGray5)),
            alignment: .top
        )
    }
}
