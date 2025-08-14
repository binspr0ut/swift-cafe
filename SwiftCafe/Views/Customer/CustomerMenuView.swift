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
    
    init(modelContext: ModelContext, tableNumber: Int) {
        self._viewModel = StateObject(wrappedValue: CustomerViewModel(modelContext: modelContext, tableNumber: tableNumber))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with cafe branding
                if let settings = viewModel.cafeSettings {
                    VStack {
                        Text(settings.cafeName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(settings.textUIColor)
                        
                        Text("Table \(viewModel.tableNumber)")
                            .font(.title2)
                            .foregroundColor(settings.accentUIColor)
                    }
                    .padding()
                }
                
                // Menu content placeholder
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.menuItems.groupedByCategory(), id: \.key) { category, items in
                            MenuCategorySection(category: category, items: items, viewModel: viewModel)
                        }
                    }
                    .padding()
                }
                
                // Order summary and checkout
                if !viewModel.currentOrder.isEmpty {
                    OrderSummaryView(viewModel: viewModel)
                }
            }
            .background(backgroundView)
        }
        .onAppear {
            viewModel.connectToAdmin()
        }
    }
    
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
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        }
    }
}

struct MenuCategorySection: View {
    let category: String
    let items: [MenuItem]
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(items.filter { $0.isAvailable }) { item in
                    MenuItemCard(item: item, viewModel: viewModel)
                }
            }
        }
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Item image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(viewModel.cafeSettings?.textUIColor ?? .primary)
                
                Text(item.menuDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.addItemToOrder(item)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct OrderSummaryView: View {
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Order")
                    .font(.headline)
                
                Spacer()
                
                Text("$\(viewModel.orderTotal, specifier: "%.2f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
            }
            
            Button("Place Order") {
                viewModel.placeOrder()
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
            .font(.headline)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
    }
}

#Preview {
    CustomerMenuView(modelContext: ModelContext(try! ModelContainer(for: MenuItem.self, CafeSettings.self)), tableNumber: 1)
}
