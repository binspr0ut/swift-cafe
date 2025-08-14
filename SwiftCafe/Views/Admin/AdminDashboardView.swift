//
//  AdminDashboardView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI
import SwiftData

struct AdminDashboardView: View {
    @StateObject private var viewModel: AdminViewModel
    @State private var showingOrderDetail: Order?
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: AdminViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            sidebar
            
            detailView
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .navigationTitle("Swift Cafe Admin")
        .sheet(item: $showingOrderDetail) { order in
            OrderDetailView(order: order, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingMenuEditor) {
            AddMenuItemView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
    
    @ViewBuilder
    private var sidebar: some View {
        List {
            ForEach(AdminViewModel.AdminTab.allCases, id: \.self) { tab in
                Button(action: {
                    viewModel.selectedTab = tab
                }) {
                    Label(tab.rawValue, systemImage: tab.icon)
                        .foregroundColor(viewModel.selectedTab == tab ? .accentColor : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Admin Panel")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Refresh") {
                        viewModel.refreshData()
                    }
                    
                    Button("Generate Demo Data") {
                        DemoDataGenerator.generateDemoOrders(modelContext: viewModel.modelContext)
                        viewModel.refreshData()
                    }
                    
                    Button("Clear All Orders") {
                        viewModel.clearAllOrders()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch viewModel.selectedTab {
        case .orders:
            OrdersView(viewModel: viewModel, showingOrderDetail: $showingOrderDetail)
        case .menu:
            MenuManagementView(viewModel: viewModel)
        case .tables:
            TablesOverviewView(viewModel: viewModel)
        case .connections:
            ConnectionStatusView(multipeerService: viewModel.multipeerService)
        case .settings:
            CafeCustomizationView(viewModel: viewModel)
        }
    }
}

// MARK: - Orders View
struct OrdersView: View {
    @ObservedObject var viewModel: AdminViewModel
    @Binding var showingOrderDetail: Order?
    
    var body: some View {
        VStack {
            // Status Overview
            HStack(spacing: 20) {
                StatusCard(title: "Pending", count: viewModel.getPendingOrders().count, color: .orange)
                StatusCard(title: "Preparing", count: viewModel.getPreparingOrders().count, color: .blue)
                StatusCard(title: "Ready", count: viewModel.getReadyOrders().count, color: .green)
            }
            .padding()
            
            // Orders List
            List {
                Section("Pending Orders") {
                    ForEach(viewModel.getPendingOrders()) { order in
                        OrderRowView(order: order, viewModel: viewModel)
                            .onTapGesture {
                                showingOrderDetail = order
                            }
                    }
                }
                
                Section("Preparing Orders") {
                    ForEach(viewModel.getPreparingOrders()) { order in
                        OrderRowView(order: order, viewModel: viewModel)
                            .onTapGesture {
                                showingOrderDetail = order
                            }
                    }
                }
                
                Section("Ready Orders") {
                    ForEach(viewModel.getReadyOrders()) { order in
                        OrderRowView(order: order, viewModel: viewModel)
                            .onTapGesture {
                                showingOrderDetail = order
                            }
                    }
                }
            }
        }
        .navigationTitle("Orders")
    }
}

struct StatusCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct OrderRowView: View {
    let order: Order
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Table \(order.tableNumber)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(order.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }
                
                Text("\(order.items.count) items • $\(order.totalAmount, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(order.dateCreated.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick action buttons
            HStack(spacing: 8) {
                if order.status == .pending {
                    Button("Start") {
                        viewModel.updateOrderStatus(order, to: .preparing)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                } else if order.status == .preparing {
                    Button("Ready") {
                        viewModel.updateOrderStatus(order, to: .ready)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.green)
                } else if order.status == .ready {
                    Button("Complete") {
                        viewModel.updateOrderStatus(order, to: .completed)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .preparing: return .blue
        case .ready: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

// MARK: - Menu Management View
struct MenuManagementView: View {
    @ObservedObject var viewModel: AdminViewModel
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.menuItems.groupedByCategory(), id: \.key) { category, items in
                    Section(category) {
                        ForEach(items) { item in
                            MenuItemRowView(item: item, viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("Menu Management")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Item") {
                        showingAddItem = true
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddMenuItemView(viewModel: viewModel)
            }
        }
    }
}

struct MenuItemRowView: View {
    let item: MenuItem
    @ObservedObject var viewModel: AdminViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.menuDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if !item.isAvailable {
                        Text("Unavailable")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Button("Edit") {
                showingEditSheet = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMenuItemView(item: item, viewModel: viewModel)
        }
    }
}

// MARK: - Tables Overview View
struct TablesOverviewView: View {
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
            ForEach(viewModel.tables) { table in
                TableStatusCard(table: table, viewModel: viewModel)
            }
        }
        .padding()
        .navigationTitle("Tables Overview")
    }
}

struct TableStatusCard: View {
    let table: Table
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "table.furniture")
                .font(.system(size: 40))
                .foregroundColor(table.isOccupied ? .red : .green)
            
            Text("Table \(table.number)")
                .font(.headline)
            
            Text(table.isOccupied ? "Occupied" : "Available")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((table.isOccupied ? Color.red : Color.green).opacity(0.2))
                .foregroundColor(table.isOccupied ? .red : .green)
                .cornerRadius(8)
            
            if table.isOccupied {
                let orders = viewModel.getOrdersForTable(table.number)
                Text("\(orders.count) orders")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text("Last activity: \(table.lastActivity.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Cafe Customization View
struct CafeCustomizationView: View {
    @ObservedObject var viewModel: AdminViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cafe Information") {
                    TextField("Cafe Name", text: Binding(
                        get: { viewModel.cafeSettings?.cafeName ?? "" },
                        set: { newValue in
                            viewModel.cafeSettings?.cafeName = newValue
                        }
                    ))
                }
                
                Section("Theme Customization") {
                    ColorPicker("Primary Button Color", selection: Binding(
                        get: { viewModel.cafeSettings?.primaryButtonUIColor ?? .blue },
                        set: { newColor in
                            viewModel.cafeSettings?.primaryButtonColor = newColor.description
                        }
                    ))
                    
                    ColorPicker("Secondary Button Color", selection: Binding(
                        get: { viewModel.cafeSettings?.secondaryButtonUIColor ?? .gray },
                        set: { newColor in
                            viewModel.cafeSettings?.secondaryButtonColor = newColor.description
                        }
                    ))
                    
                    ColorPicker("Text Color", selection: Binding(
                        get: { viewModel.cafeSettings?.textUIColor ?? .black },
                        set: { newColor in
                            viewModel.cafeSettings?.textColor = newColor.description
                        }
                    ))
                    
                    ColorPicker("Accent Color", selection: Binding(
                        get: { viewModel.cafeSettings?.accentUIColor ?? .orange },
                        set: { newColor in
                            viewModel.cafeSettings?.accentColor = newColor.description
                        }
                    ))
                }
                
                Section("Background") {
                    TextField("Background Image Name", text: Binding(
                        get: { viewModel.cafeSettings?.backgroundImageName ?? "" },
                        set: { newValue in
                            viewModel.cafeSettings?.backgroundImageName = newValue.isEmpty ? nil : newValue
                        }
                    ))
                }
                
                Section("Connected Devices") {
                    ForEach(viewModel.connectedTables, id: \.displayName) { peer in
                        HStack {
                            Image(systemName: "ipad")
                            Text(peer.displayName)
                            Spacer()
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if viewModel.connectedTables.isEmpty {
                        Text("No devices connected")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cafe Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save Changes") {
                        if let settings = viewModel.cafeSettings {
                            viewModel.updateCafeSettings(settings)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
