//
//  Table.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData

@Model
final class Table {
    var id: UUID
    var number: Int
    var isOccupied: Bool
    var currentOrderId: UUID?
    var lastActivity: Date
    var peerID: String? // For MultipeerConnectivity
    
    init(number: Int) {
        self.id = UUID()
        self.number = number
        self.isOccupied = false
        self.lastActivity = Date()
    }
    
    func updateActivity() {
        self.lastActivity = Date()
    }
}
