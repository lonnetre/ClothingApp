//
//  OutfitBuilderViewModel.swift
//  ClothingApp
//
//  Created by yehor on 26.04.25.
//

import SwiftUI
import CoreData

class OutfitBuilderViewModel: ObservableObject {
    /// Published - to mark properties that, when changed, should trigger view updates
    @Published var clothingPages: [ClothingCategory: ClothingPage] = [:]
    @Published var selectedTab = 0
    @Published var weatherTemperature = "18°C"
    
    init() {
        setupInitialData()
    }
    
    private func setupInitialData() {
        // Set up hats
        let hats = [
            ClothingItem(name: "Gray Cap", imageName: "cap_gray", category: .hats),
            ClothingItem(name: "Black Cap", imageName: "cap_black", category: .hats),
            ClothingItem(name: "Gray Cap 2", imageName: "cap_gray", category: .hats)
        ]
        clothingPages[.hats] = ClothingPage(items: hats, selectedItemIndex: 1, currentPage: 2, totalPages: 3)
        
        // Set up tops
        let cutoutTops = loadCutoutsFromCoreData()
        let tops = cutoutTops + [
            ClothingItem(name: "Gray T-Shirt", imageName: "tshirt_cyan", category: .tops),
            ClothingItem(name: "Blue T-Shirt", imageName: "tshirt_blue", category: .tops),
            ClothingItem(name: "Red T-Shirt", imageName: "tshirt_red", category: .tops)
        ]
        clothingPages[.tops] = ClothingPage(
            items: tops,
            selectedItemIndex: 0,
            currentPage: 1,
            totalPages: tops.count
        )
        
        // Set up bottoms
        let bottoms = [
            ClothingItem(name: "Gray Jeans", imageName: "jeans_gray", category: .bottoms),
            ClothingItem(name: "Blue Jeans", imageName: "jeans_blue", category: .bottoms),
            ClothingItem(name: "Gray Jeans 2", imageName: "jeans_gray", category: .bottoms)
        ]
        clothingPages[.bottoms] = ClothingPage(items: bottoms, selectedItemIndex: 1, currentPage: 2, totalPages: 3)
        
        // Set up shoes
        let shoes = [
            ClothingItem(name: "Gray Shoes", imageName: "shoes_gray", category: .shoes),
            ClothingItem(name: "Black Shoes", imageName: "shoes_black", category: .shoes),
            ClothingItem(name: "Gray Shoes 2", imageName: "shoes_gray", category: .shoes)
        ]
        clothingPages[.shoes] = ClothingPage(items: shoes, selectedItemIndex: 1, currentPage: 2, totalPages: 3)
    }
    
    func selectItem(category: ClothingCategory, index: Int) {
        guard var page = clothingPages[category], index < page.items.count else { return }
        page.selectedItemIndex = index
        page.currentPage = index + 1
        clothingPages[category] = page
    }
    
    func nextPage(for category: ClothingCategory) {
        guard var page = clothingPages[category] else { return }
        if page.currentPage < page.totalPages {
            page.currentPage += 1
            // Here you would load new items for this page
            clothingPages[category] = page
        }
    }
    
    func previousPage(for category: ClothingCategory) {
        guard var page = clothingPages[category] else { return }
        if page.currentPage > 1 {
            page.currentPage -= 1
            // Here you would load new items for this page
            clothingPages[category] = page
        }
    }
    
    func updatePage(for category: ClothingCategory, page: Int) {
        guard var pageData = clothingPages[category] else { return }
        pageData.currentPage = page
        clothingPages[category] = pageData
    }
    
    func createOutfit() {
        // Logic to save the current outfit
        print("Creating outfit with selected items")
    }
    
    func swapOutfits() {
        // Logic to randomly swap outfit items
        print("Swapping outfit items")
    }
    
    func loadCutoutsFromCoreData() -> [ClothingItem] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<CutoutImage> = CutoutImage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            
            let tops = results.filter {
                ($0.tags?.contains("cutout") == true) || ($0.tags?.contains("tops") == true)
            }
            
            let items: [ClothingItem] = tops.compactMap { cutout in
                guard let image = cutout.image as? UIImage,
                      let id = cutout.id else { return nil }
                
                return ClothingItem(
                    name: "Saved T-Shirt",
                    imageName: id.uuidString,
                    category: .tops,
                    uiImage: image
                )
            }
            
            return items
        } catch {
            print("❌ Failed to load cutouts: \(error)")
            return []
        }
    }
}
