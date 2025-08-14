//
//  CafeSettings.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class CafeSettings {
    var id: UUID
    var backgroundImageName: String?
    var primaryButtonColor: String
    var secondaryButtonColor: String
    var textColor: String
    var accentColor: String
    var cafeName: String
    var logoImageName: String?
    var dateModified: Date
    
    init(cafeName: String = "Swift Cafe", backgroundImageName: String? = nil, primaryButtonColor: String = "blue", secondaryButtonColor: String = "gray", textColor: String = "black", accentColor: String = "orange", logoImageName: String? = nil) {
        self.id = UUID()
        self.cafeName = cafeName
        self.backgroundImageName = backgroundImageName
        self.primaryButtonColor = primaryButtonColor
        self.secondaryButtonColor = secondaryButtonColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.logoImageName = logoImageName
        self.dateModified = Date()
    }
    
    var primaryButtonUIColor: Color {
        Color(primaryButtonColor)
    }
    
    var secondaryButtonUIColor: Color {
        Color(secondaryButtonColor)
    }
    
    var textUIColor: Color {
        Color(textColor)
    }
    
    var accentUIColor: Color {
        Color(accentColor)
    }
}
