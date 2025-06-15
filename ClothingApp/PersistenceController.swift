//
//  PersistenceController.swift
//  ClothingApp
//
//  Created by yehor on 15.06.25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "ImageModel") // Match your .xcdatamodeld file name

        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unable to load Core Data store: \(error)")
            }
        }
    }
}
