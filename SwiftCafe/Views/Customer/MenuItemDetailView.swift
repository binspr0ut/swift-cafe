//
//  MenuItemDetailView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct MenuItemDetailView: View {
    let item: MenuItem
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = 1
    @State private var specialInstructions = ""
    @State private var showingAddedToCart = false
    
    private var totalPrice: Double {
        Double(quantity) * item.price
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Item image
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    viewModel.cafeSettings?.accentUIColor.opacity(0.4) ?? Color.orange.opacity(0.4),
                                    viewModel.cafeSettings?.primaryButtonUIColor.opacity(0.2) ?? Color.blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 250)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "cup.and.saucer")
                                .font(.system(size: 64))
                                .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            
                            Text(item.category)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Item details
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.cafeSettings?.textUIColor ?? .primary)
                                
                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                Text("\(item.preparationTime) min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Text(item.menuDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                        
                        // Quantity selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantity")
                                .font(.headline)
                            
                            HStack {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .red : .gray)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 40)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Special instructions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Special Instructions")
                                .font(.headline)
                            
                            TextField("Add any special requests...", text: $specialInstructions)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3)
                        }
                        
                        Divider()
                        
                        // Total and add button
                        VStack(spacing: 16) {
                            HStack {
                                Text("Total")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("$\(totalPrice, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            }
                            
                            Button(action: addToCart) {
                                HStack {
                                    Image(systemName: "cart.badge.plus")
                                    Text("Add \(quantity) to Cart - $\(String(format: "%.2f", totalPrice))")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Menu Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Added to Cart!", isPresented: $showingAddedToCart) {
                Button("Continue Shopping") { 
                    dismiss()
                }
                Button("View Cart") {
                    dismiss()
                    // This would need to be communicated back to parent
                }
            } message: {
                Text("\(quantity) \(item.name) added to your cart")
            }
        }
    }
    
    private func addToCart() {
        viewModel.addToCart(
            item: item,
            quantity: quantity,
            specialInstructions: specialInstructions
        )
        showingAddedToCart = true
    }
}
