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
    
    let tableNumber: Int
    private var modelContext: ModelContext
    private let multipeerService: MultipeerService
    
    var orderTotal: Double {
        currentOrder.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
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
    
    func addItemToOrder(_ menuItem: MenuItem) {
        if let existingItem = currentOrder.first(where: { $0.menuItemId == menuItem.id }) {
            existingItem.quantity += 1
        } else {
            let orderItem = OrderItem(
                menuItemId: menuItem.id,
                name: menuItem.name,
                price: menuItem.price,
                quantity: 1
            )
            currentOrder.append(orderItem)
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
    
    func placeOrder() {
        guard !currentOrder.isEmpty else { return }
        
        let order = Order(tableNumber: tableNumber, orderItems: currentOrder)
        
        // Save locally first
        modelContext.insert(order)
        
        do {
            try modelContext.save()
            
            // Send to admin
            multipeerService.sendOrder(order)
            
            // Clear current order and show confirmation
            currentOrder.removeAll()
            showingOrderConfirmation = true
            orderStatus = .pending
            
        } catch {
            print("Error saving order: \(error)")
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
