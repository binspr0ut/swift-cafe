//
//  AdminViewModel.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import SwiftData
import SwiftUI
import MultipeerConnectivity

@MainActor
class AdminViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var menuItems: [MenuItem] = []
    @Published var tables: [Table] = []
    @Published var cafeSettings: CafeSettings?
    @Published var connectedTables: [MCPeerID] = []
    @Published var selectedTab: AdminTab = .orders
    @Published var showingOrderDetail: Order?
    @Published var showingSettings = false
    @Published var showingMenuEditor = false
    
    private var context: ModelContext
    private let multipeerService: MultipeerService
    
    enum AdminTab: String, CaseIterable {
        case orders = "Orders"
        case menu = "Menu"
        case tables = "Tables"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .orders: return "list.clipboard"
            case .menu: return "menucard"
            case .tables: return "table.furniture"
            case .settings: return "gearshape"
            }
        }
    }
    
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.multipeerService = MultipeerService()
        
        setupMultipeerService()
        loadData()
        createDefaultDataIfNeeded()
    }
    
    private func setupMultipeerService() {
        multipeerService.delegate = self
        multipeerService.startAdvertising()
        multipeerService.startBrowsing()
    }
    
    private func loadData() {
        loadOrders()
        loadMenuItems()
        loadTables()
        loadCafeSettings()
    }
    
    private func loadOrders() {
        let descriptor = FetchDescriptor<Order>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        
        do {
            orders = try context.fetch(descriptor)
        } catch {
            print("Error loading orders: \(error)")
        }
    }
    
    private func loadMenuItems() {
        let descriptor = FetchDescriptor<MenuItem>(
            sortBy: [SortDescriptor(\.category), SortDescriptor(\.name)]
        )
        
        do {
            menuItems = try context.fetch(descriptor)
        } catch {
            print("Error loading menu items: \(error)")
        }
    }
    
    private func loadTables() {
        let descriptor = FetchDescriptor<Table>(
            sortBy: [SortDescriptor(\.number)]
        )
        
        do {
            tables = try context.fetch(descriptor)
        } catch {
            print("Error loading tables: \(error)")
        }
    }
    
    private func loadCafeSettings() {
        let descriptor = FetchDescriptor<CafeSettings>()
        
        do {
            let settings = try context.fetch(descriptor)
            cafeSettings = settings.first
        } catch {
            print("Error loading cafe settings: \(error)")
        }
    }
    
    private func createDefaultDataIfNeeded() {
        // Create default settings if none exist
        if cafeSettings == nil {
            let defaultSettings = CafeSettings()
            context.insert(defaultSettings)
            cafeSettings = defaultSettings
            saveContext()
        }
        
        // Create default tables if none exist
        if tables.isEmpty {
            for i in 1...6 {
                let table = Table(number: i)
                context.insert(table)
                tables.append(table)
            }
            saveContext()
        }
        
        // Create default menu items if none exist
        if menuItems.isEmpty {
            createDefaultMenu()
        }
    }
    
    private func createDefaultMenu() {
        let defaultItems = [
            MenuItem(name: "Espresso", description: "Rich and bold single shot", price: 3.50, category: "Coffee"),
            MenuItem(name: "Cappuccino", description: "Espresso with steamed milk and foam", price: 4.50, category: "Coffee"),
            MenuItem(name: "Latte", description: "Espresso with steamed milk", price: 5.00, category: "Coffee"),
            MenuItem(name: "Americano", description: "Espresso with hot water", price: 3.00, category: "Coffee"),
            MenuItem(name: "Croissant", description: "Buttery, flaky pastry", price: 3.00, category: "Pastry"),
            MenuItem(name: "Blueberry Muffin", description: "Fresh baked with real blueberries", price: 3.50, category: "Pastry"),
            MenuItem(name: "Avocado Toast", description: "Smashed avocado on sourdough", price: 8.00, category: "Food"),
            MenuItem(name: "Caesar Salad", description: "Crisp romaine with parmesan", price: 12.00, category: "Food")
        ]
        
        for item in defaultItems {
            context.insert(item)
            menuItems.append(item)
        }
        saveContext()
        
        // Send menu to connected peers
        multipeerService.sendMenuUpdate(menuItems)
    }
    
    func updateOrderStatus(_ order: Order, to status: OrderStatus) {
        order.status = status
        if status == .completed {
            order.dateCompleted = Date()
        }
        saveContext()
        loadOrders() // Refresh the list
    }
    
    func addMenuItem(_ item: MenuItem) {
        context.insert(item)
        menuItems.append(item)
        saveContext()
        multipeerService.sendMenuUpdate(menuItems)
    }
    
    func updateMenuItem(_ item: MenuItem) {
        item.dateModified = Date()
        saveContext()
        loadMenuItems()
        multipeerService.sendMenuUpdate(menuItems)
    }
    
    func deleteMenuItem(_ item: MenuItem) {
        context.delete(item)
        menuItems.removeAll { $0.id == item.id }
        saveContext()
        multipeerService.sendMenuUpdate(menuItems)
    }
    
    func updateCafeSettings(_ settings: CafeSettings) {
        settings.dateModified = Date()
        cafeSettings = settings
        saveContext()
        multipeerService.sendSettingsUpdate(settings)
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func refreshData() {
        loadData()
    }
    
    func clearAllOrders() {
        let descriptor = FetchDescriptor<Order>()
        
        do {
            let allOrders = try context.fetch(descriptor)
            for order in allOrders {
                context.delete(order)
            }
            try context.save()
            orders.removeAll()
        } catch {
            print("Error clearing orders: \(error)")
        }
    }
    
    var modelContext: ModelContext {
        return self.context
    }
    
    // MARK: - Order Management
    func getOrdersForTable(_ tableNumber: Int) -> [Order] {
        return orders.filter { $0.tableNumber == tableNumber }
    }
    
    func getPendingOrders() -> [Order] {
        return orders.filter { $0.status == .pending }
    }
    
    func getPreparingOrders() -> [Order] {
        return orders.filter { $0.status == .preparing }
    }
    
    func getReadyOrders() -> [Order] {
        return orders.filter { $0.status == .ready }
    }
    
    // MARK: - Table Management
    func getTableStatus(_ tableNumber: Int) -> String {
        guard let table = tables.first(where: { $0.number == tableNumber }) else {
            return "Unknown"
        }
        
        return table.isOccupied ? "Occupied" : "Available"
    }
}

// MARK: - MultipeerServiceDelegate
extension AdminViewModel: MultipeerServiceDelegate {
    func didReceiveOrder(_ order: Order) {
        // Insert the new order into the context
        context.insert(order)
        orders.append(order)
        saveContext()
        
        // Update table status
        if let table = tables.first(where: { $0.number == order.tableNumber }) {
            table.isOccupied = true
            table.currentOrderId = order.id
            table.updateActivity()
            saveContext()
        }
    }
    
    func didReceiveSettingsUpdate(_ settings: CafeSettings) {
        // This shouldn't happen as admin sends settings, not receives
    }
    
    func didReceiveMenuUpdate(_ menu: [MenuItem]) {
        // This shouldn't happen as admin sends menu updates, not receives
    }
    
    func peerDidConnect(_ peerID: MCPeerID) {
        connectedTables.append(peerID)
        
        // Send current menu and settings to newly connected peer
        if let settings = cafeSettings {
            multipeerService.sendSettingsUpdate(settings)
        }
        multipeerService.sendMenuUpdate(menuItems)
    }
    
    func peerDidDisconnect(_ peerID: MCPeerID) {
        connectedTables.removeAll { $0 == peerID }
    }
}
