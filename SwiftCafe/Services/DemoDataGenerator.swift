//
//  DemoDataGenerator.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData

class DemoDataGenerator {
    static func generateDemoOrders(modelContext: ModelContext) {
        // Create some demo orders for testing
        let demoOrders = [
            createDemoOrder(tableNumber: 1, items: [
                ("Cappuccino", 4.50, 2),
                ("Croissant", 3.00, 1)
            ], status: .preparing, modelContext: modelContext),
            
            createDemoOrder(tableNumber: 3, items: [
                ("Latte", 5.00, 1),
                ("Avocado Toast", 8.00, 1),
                ("Blueberry Muffin", 3.50, 2)
            ], status: .ready, modelContext: modelContext),
            
            createDemoOrder(tableNumber: 5, items: [
                ("Espresso", 3.50, 3),
                ("Caesar Salad", 12.00, 1)
            ], status: .pending, modelContext: modelContext)
        ]
        
        for order in demoOrders {
            modelContext.insert(order)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving demo orders: \(error)")
        }
    }
    
    private static func createDemoOrder(
        tableNumber: Int,
        items: [(name: String, price: Double, quantity: Int)],
        status: OrderStatus,
        modelContext: ModelContext
    ) -> Order {
        let orderItems = items.map { item in
            OrderItem(
                menuItemId: UUID(),
                name: item.name,
                price: item.price,
                quantity: item.quantity
            )
        }
        
        let order = Order(tableNumber: tableNumber, orderItems: orderItems)
        order.status = status
        
        // Adjust timestamps for demo purposes
        let now = Date()
        switch status {
        case .preparing:
            order.dateCreated = now.addingTimeInterval(-900) // 15 minutes ago
        case .ready:
            order.dateCreated = now.addingTimeInterval(-1800) // 30 minutes ago
        case .completed:
            order.dateCreated = now.addingTimeInterval(-3600) // 1 hour ago
            order.dateCompleted = now.addingTimeInterval(-300) // completed 5 minutes ago
        default:
            order.dateCreated = now.addingTimeInterval(-300) // 5 minutes ago
        }
        
        return order
    }
    
    static func generateDemoSettings(modelContext: ModelContext) -> CafeSettings {
        let settings = CafeSettings(
            cafeName: "Swift Cafe",
            backgroundImageName: nil,
            primaryButtonColor: "#007AFF",
            secondaryButtonColor: "#8E8E93",
            textColor: "#000000",
            accentColor: "#FF9500",
            logoImageName: nil
        )
        
        modelContext.insert(settings)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving demo settings: \(error)")
        }
        
        return settings
    }
}
