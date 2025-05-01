//
//  ClothingPage.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

struct ClothingPage {
    let items: [ClothingItem]
    var selectedItemIndex: Int = 0
    var currentPage: Int = 1
    let totalPages: Int
    
    var selectedItem: ClothingItem {
        items[selectedItemIndex]
    }
}
