//
//  MenuItem.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData

@Model
final class MenuItem {
    var id: UUID
    var name: String
    var menuDescription: String
    var price: Double
    var category: String
    var imageName: String?
    var isAvailable: Bool
    var preparationTime: Int // in minutes
    var dateCreated: Date
    var dateModified: Date
    
    init(name: String, description: String, price: Double, category: String, imageName: String? = nil, isAvailable: Bool = true, preparationTime: Int = 10) {
        self.id = UUID()
        self.name = name
        self.menuDescription = description
        self.price = price
        self.category = category
        self.imageName = imageName
        self.isAvailable = isAvailable
        self.preparationTime = preparationTime
        self.dateCreated = Date()
        self.dateModified = Date()
    }
}
