//
//  UIImageTransformer.swift
//  ClothingApp
//
//  Created by yehor on 15.06.25.
//

import UIKit

@objc(UIImageTransformer)
class UIImageTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? UIImage else { return nil }
        return image.jpegData(compressionQuality: 1.0)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return UIImage(data: data)
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: "UIImageTransformer")
        let transformer = UIImageTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
