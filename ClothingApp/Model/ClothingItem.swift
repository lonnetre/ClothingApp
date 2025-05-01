//
//  ClothingItem.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct ClothingItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let category: ClothingCategory
}
