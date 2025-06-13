//
//  ClothingCategory.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI

enum ClothingCategory: String, CaseIterable {
    case hats = "Hats"
    case tops = "Tops"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    
    var preferredHeight: CGFloat {
        switch self {
        case .hats, .shoes:
            return UIScreen.main.bounds.height / 12  // Smaller height for hats and shoes
        case .tops, .bottoms:
            return UIScreen.main.bounds.height / 6 // Larger height for tops and bottoms
        }
    }
}
