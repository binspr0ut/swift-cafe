//
//  CustomerMenuView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI
import SwiftData

struct CustomerMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CustomerViewModel
    @State private var selectedCategory: String = "All"
    @State private var showingCart = false
    @State private var showingOrderStatus = false
    @State private var showingStaffCall = false
    
    init(modelContext: ModelContext, tableNumber: Int) {
        self._viewModel = StateObject(wrappedValue: CustomerViewModel(modelContext: modelContext, tableNumber: tableNumber))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                
                VStack(spacing: 0) {
                    // Header with cafe branding and status
                    headerView
                    
                    // Category selector
                    categorySelector
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Menu items (left side)
                        menuContentView
                            .frame(width: geometry.size.width * 0.7)
                        
                        // Order summary (right side)
                        orderSidebarView
                            .frame(width: geometry.size.width * 0.3)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCart) {
            CartView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingOrderStatus) {
            OrderStatusView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingStaffCall) {
            StaffCallView(viewModel: viewModel)
        }
        .alert("Order Placed Successfully!", isPresented: $viewModel.showingOrderConfirmation) {
            Button("View Status") {
                showingOrderStatus = true
            }
            Button("Continue Shopping") { }
        } message: {
            Text("Your order has been sent to the kitchen. You can track its progress in the order status.")
        }
        .onAppear {
            viewModel.connectToAdmin()
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var backgroundView: some View {
        if let backgroundImageName = viewModel.cafeSettings?.backgroundImageName,
           !backgroundImageName.isEmpty {
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.1)
        } else {
            LinearGradient(
                gradient: Gradient(colors: [
                    viewModel.cafeSettings?.primaryButtonUIColor.opacity(0.1) ?? Color.blue.opacity(0.1),
                    viewModel.cafeSettings?.accentUIColor.opacity(0.05) ?? Color.orange.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                // Cafe branding
                VStack(alignment: .leading) {
                    if let settings = viewModel.cafeSettings {
                        Text(settings.cafeName)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(settings.textUIColor)
                        
                        Text("Table \(viewModel.tableNumber)")
                            .font(.title2)
                            .foregroundColor(settings.accentUIColor)
                    }
                }
                
                Spacer()
                
                // Connection status and actions
                HStack(spacing: 16) {
                    // Connection status
                    HStack {
                        Circle()
                            .fill(viewModel.isConnectedToAdmin ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(viewModel.isConnectedToAdmin ? "Connected" : "Disconnected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Order status button
                    if viewModel.hasActiveOrder {
                        Button(action: { showingOrderStatus = true }) {
                            HStack {
                                Image(systemName: "clock")
                                Text("Order Status")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    
                    // Call staff button
                    Button(action: { showingStaffCall = true }) {
                        HStack {
                            Image(systemName: "bell")
                            Text("Call Staff")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.cafeSettings?.secondaryButtonUIColor ?? .gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                }
            }
            
            Divider()
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryButton(
                    title: "All",
                    isSelected: selectedCategory == "All",
                    settings: viewModel.cafeSettings
                ) {
                    selectedCategory = "All"
                }
                
                // Individual category buttons
                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: selectedCategory == category,
                        settings: viewModel.cafeSettings
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var menuContentView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(filteredMenuItems, id: \.id) { item in
                    MenuItemCard(item: item, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private var orderSidebarView: some View {
        VStack(spacing: 0) {
            // Cart header
            HStack {
                Text("Your Order")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !viewModel.currentOrder.isEmpty {
                    Text("\(viewModel.currentOrder.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            if viewModel.currentOrder.isEmpty {
                // Empty cart state
                VStack(spacing: 16) {
                    Image(systemName: "cart")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Your cart is empty")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add items from the menu to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Cart items
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.currentOrder, id: \.id) { item in
                            CartItemRow(item: item, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                
                // Cart summary and checkout
                VStack(spacing: 12) {
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("$\(viewModel.orderTotal, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 8) {
                        Button("Place Order") {
                            viewModel.placeOrder()
                        }
                        .buttonStyle(PrimaryButtonStyle(settings: viewModel.cafeSettings))
                        
                        Button("Clear Cart") {
                            viewModel.clearOrder()
                        }
                        .buttonStyle(SecondaryButtonStyle(settings: viewModel.cafeSettings))
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12, corners: [.topLeft, .bottomLeft])
    }
    
    private var filteredMenuItems: [MenuItem] {
        let items = selectedCategory == "All" ? viewModel.menuItems : viewModel.menuItems.filter { $0.category == selectedCategory }
        return items.filter { $0.isAvailable }
    }
}


// MARK: - Supporting Views

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let settings: CafeSettings?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? (settings?.primaryButtonUIColor ?? .blue) : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: CustomerViewModel
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Item image with overlay
                ZStack(alignment: .topTrailing) {
                    // Image placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                viewModel.cafeSettings?.accentUIColor.opacity(0.3) ?? Color.orange.opacity(0.3),
                                viewModel.cafeSettings?.primaryButtonUIColor.opacity(0.1) ?? Color.blue.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 140)
                        .overlay(
                            VStack {
                                Image(systemName: "cup.and.saucer")
                                    .font(.system(size: 32))
                                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                    
                    // Preparation time badge
                    Text("\(item.preparationTime) min")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.cafeSettings?.textUIColor ?? .primary)
                        
                        Spacer()
                        
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                    }
                    
                    Text(item.menuDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Add to cart button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewModel.addItemToOrder(item)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .buttonStyle(.plain)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingDetails) {
            MenuItemDetailView(item: item, viewModel: viewModel)
        }
    }
}

struct CartItemRow: View {
    let item: OrderItem
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let instructions = item.specialInstructions, !instructions.isEmpty {
                    Text("Note: \(instructions)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Text("$\(item.price, specifier: "%.2f") each")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                // Quantity controls
                HStack(spacing: 4) {
                    Button(action: {
                        if item.quantity > 1 {
                            viewModel.updateItemQuantity(item, quantity: item.quantity - 1)
                        } else {
                            viewModel.removeItemFromOrder(item)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        viewModel.updateItemQuantity(item, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                    }
                }
                
                Text("$\(Double(item.quantity) * item.price, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    CustomerMenuView(modelContext: ModelContext(try! ModelContainer(for: MenuItem.self, CafeSettings.self)), tableNumber: 1)
}
