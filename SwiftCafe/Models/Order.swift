//
//  Order.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData

@Model
final class Order {
    var id: UUID
    var tableNumber: Int
    var orderItems: [OrderItem]
    var totalAmount: Double
    var status: OrderStatus
    var dateCreated: Date
    var dateCompleted: Date?
    var customerNotes: String?
    
    init(tableNumber: Int, orderItems: [OrderItem] = [], customerNotes: String? = nil) {
        self.id = UUID()
        self.tableNumber = tableNumber
        self.orderItems = orderItems
        self.totalAmount = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        self.status = .pending
        self.dateCreated = Date()
        self.customerNotes = customerNotes
    }
    
    var items: [OrderItem] {
        get { orderItems }
        set { 
            orderItems = newValue
            updateTotal()
        }
    }
    
    func updateTotal() {
        self.totalAmount = orderItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case preparing = "Preparing"
    case ready = "Ready"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

@Model
final class OrderItem {
    var id: UUID
    var menuItemId: UUID
    var name: String
    var price: Double
    var quantity: Int
    var specialInstructions: String?
    
    init(menuItemId: UUID, name: String, price: Double, quantity: Int, specialInstructions: String? = nil) {
        self.id = UUID()
        self.menuItemId = menuItemId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.specialInstructions = specialInstructions
    }
}
