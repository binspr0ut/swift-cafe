//
//  CustomerViewModel.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData
import SwiftUI
import MultipeerConnectivity

@MainActor
class CustomerViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var cafeSettings: CafeSettings?
    @Published var currentOrder: [OrderItem] = []
    @Published var isConnectedToAdmin = false
    @Published var orderStatus: OrderStatus?
    @Published var showingOrderConfirmation = false
    @Published var activeOrder: Order?
    @Published var orderHistory: [Order] = []
    
    let tableNumber: Int
    private var modelContext: ModelContext
    private let multipeerService: MultipeerService
    
    var orderTotal: Double {
        currentOrder.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var estimatedPreparationTime: Int {
        // Estimate 5-15 minutes per item based on quantity
        currentOrder.reduce(0) { total, item in
            total + (10 * item.quantity) // 10 minutes per item as default
        }
    }
    
    var availableCategories: [String] {
        Array(Set(menuItems.map { $0.category })).sorted()
    }
    
    var hasActiveOrder: Bool {
        activeOrder != nil && ![.completed, .cancelled].contains(activeOrder?.status)
    }
    
    private var preparationTimeMapping: [UUID: Int] = [:]
    
    init(modelContext: ModelContext, tableNumber: Int) {
        self.modelContext = modelContext
        self.tableNumber = tableNumber
        self.multipeerService = MultipeerService()
        
        setupMultipeerService()
        loadLocalData()
    }
    
    private func setupMultipeerService() {
        multipeerService.delegate = self
        multipeerService.startBrowsing()
    }
    
    private func loadLocalData() {
        // Load cached menu items and settings
        loadMenuItems()
        loadCafeSettings()
    }
    
    private func loadMenuItems() {
        let descriptor = FetchDescriptor<MenuItem>(
            sortBy: [SortDescriptor(\.category), SortDescriptor(\.name)]
        )
        
        do {
            menuItems = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading menu items: \(error)")
        }
    }
    
    private func loadCafeSettings() {
        let descriptor = FetchDescriptor<CafeSettings>()
        
        do {
            let settings = try modelContext.fetch(descriptor)
            cafeSettings = settings.first
        } catch {
            print("Error loading cafe settings: \(error)")
        }
    }
    
    func connectToAdmin() {
        multipeerService.startBrowsing()
    }
    
    func addItemToOrder(_ menuItem: MenuItem, specialInstructions: String = "") {
        if let existingItem = currentOrder.first(where: { 
            $0.menuItemId == menuItem.id && $0.specialInstructions == specialInstructions 
        }) {
            existingItem.quantity += 1
        } else {
            let orderItem = OrderItem(
                menuItemId: menuItem.id,
                name: menuItem.name,
                price: menuItem.price,
                quantity: 1,
                specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
            )
            currentOrder.append(orderItem)
        }
    }
    
    func addToCart(item: MenuItem, quantity: Int = 1, specialInstructions: String = "") {
        addItemToOrder(item, specialInstructions: specialInstructions)
        if quantity > 1 {
            if let lastItem = currentOrder.last {
                lastItem.quantity = quantity
            }
        }
    }
    
    func removeItemFromOrder(_ orderItem: OrderItem) {
        currentOrder.removeAll { $0.id == orderItem.id }
    }
    
    func updateItemQuantity(_ orderItem: OrderItem, quantity: Int) {
        if quantity <= 0 {
            removeItemFromOrder(orderItem)
        } else {
            orderItem.quantity = quantity
        }
    }
    
    func placeOrder(customerNotes: String = "") {
        guard !currentOrder.isEmpty else { return }
        
        let order = Order(
            tableNumber: tableNumber, 
            orderItems: currentOrder,
            customerNotes: customerNotes
        )
        
        // Save locally first
        modelContext.insert(order)
        
        do {
            try modelContext.save()
            
            // Send to admin
            multipeerService.sendOrder(order)
            
            // Clear current order and show confirmation
            activeOrder = order
            currentOrder.removeAll()
            showingOrderConfirmation = true
            orderStatus = .pending
            
        } catch {
            print("Error saving order: \(error)")
        }
    }
    
    func callStaff(reason: String) {
        let staffCall = StaffCall(
            tableNumber: tableNumber,
            reason: reason,
            timestamp: Date()
        )
        
        // Send staff call to admin - we'll implement this in MultipeerService
        print("Staff called for table \(tableNumber): \(reason)")
    }
    
    func loadActiveOrder() {
        // Implementation to load any active order for this table
        let currentTableNumber = self.tableNumber
        let descriptor = FetchDescriptor<Order>(
            sortBy: [SortDescriptor(\Order.dateCreated, order: .reverse)]
        )
        
        do {
            let allOrders = try modelContext.fetch(descriptor)
            activeOrder = allOrders.first { order in
                order.tableNumber == currentTableNumber &&
                order.status != .completed &&
                order.status != .cancelled
            }
        } catch {
            print("Error loading active order: \(error)")
        }
    }
    
    func clearOrder() {
        currentOrder.removeAll()
    }
}

// MARK: - MultipeerServiceDelegate
extension CustomerViewModel: MultipeerServiceDelegate {
    func didReceiveOrder(_ order: Order) {
        // Customer doesn't typically receive orders, but could be used for order updates
        if order.tableNumber == tableNumber {
            orderStatus = order.status
        }
    }
    
    func didReceiveSettingsUpdate(_ settings: CafeSettings) {
        // Update local settings when admin changes them
        if let existingSettings = cafeSettings {
            // Update existing settings
            existingSettings.cafeName = settings.cafeName
            existingSettings.backgroundImageName = settings.backgroundImageName
            existingSettings.primaryButtonColor = settings.primaryButtonColor
            existingSettings.secondaryButtonColor = settings.secondaryButtonColor
            existingSettings.textColor = settings.textColor
            existingSettings.accentColor = settings.accentColor
            existingSettings.logoImageName = settings.logoImageName
        } else {
            // Insert new settings
            modelContext.insert(settings)
            cafeSettings = settings
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving settings update: \(error)")
        }
    }
    
    func didReceiveMenuUpdate(_ menu: [MenuItem]) {
        // Clear existing menu items and insert new ones
        let descriptor = FetchDescriptor<MenuItem>()
        
        do {
            let existingItems = try modelContext.fetch(descriptor)
            for item in existingItems {
                modelContext.delete(item)
            }
            
            for item in menu {
                modelContext.insert(item)
            }
            
            try modelContext.save()
            menuItems = menu
            
        } catch {
            print("Error updating menu: \(error)")
        }
    }
    
    func peerDidConnect(_ peerID: MCPeerID) {
        isConnectedToAdmin = true
        print("Connected to admin: \(peerID.displayName)")
    }
    
    func peerDidDisconnect(_ peerID: MCPeerID) {
        isConnectedToAdmin = false
        print("Disconnected from admin: \(peerID.displayName)")
    }
}
