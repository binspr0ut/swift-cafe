//
//  CartView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var customerNotes = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.currentOrder.isEmpty {
                    // Empty cart state
                    VStack(spacing: 24) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Browse our menu and add items to your cart")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Cart items
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.currentOrder, id: \.id) { item in
                                CartItemDetailRow(item: item, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                    
                    // Customer notes section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Notes")
                            .font(.headline)
                        
                        TextField("Any special requests for your order...", text: $customerNotes)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3)
                    }
                    .padding(.horizontal)
                    
                    // Order summary and checkout
                    VStack(spacing: 16) {
                        Divider()
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                    .font(.body)
                                Spacer()
                                Text("$\(viewModel.orderTotal, specifier: "%.2f")")
                                    .font(.body)
                            }
                            
                            HStack {
                                Text("Estimated Time")
                                    .font(.body)
                                Spacer()
                                Text("\(viewModel.estimatedPreparationTime) min")
                                    .font(.body)
                                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            }
                            
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
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button("Place Order") {
                                viewModel.placeOrder(customerNotes: customerNotes)
                                dismiss()
                            }
                            .buttonStyle(PrimaryButtonStyle(settings: viewModel.cafeSettings))
                            
                            Button("Clear Cart") {
                                viewModel.clearOrder()
                            }
                            .buttonStyle(SecondaryButtonStyle(settings: viewModel.cafeSettings))
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    .background(Color(.systemGray6))
                }
            }
            .navigationTitle("Your Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Continue Shopping") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CartItemDetailRow: View {
    let item: OrderItem
    @ObservedObject var viewModel: CustomerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("$\(item.price, specifier: "%.2f") each")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let instructions = item.specialInstructions, !instructions.isEmpty {
                        Text("Note: \(instructions)")
                            .font(.caption)
                            .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                            .italic()
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    // Quantity controls
                    HStack(spacing: 8) {
                        Button(action: {
                            if item.quantity > 1 {
                                viewModel.updateItemQuantity(item, quantity: item.quantity - 1)
                            } else {
                                viewModel.removeItemFromOrder(item)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            viewModel.updateItemQuantity(item, quantity: item.quantity + 1)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(viewModel.cafeSettings?.primaryButtonUIColor ?? .blue)
                        }
                    }
                    
                    Text("$\(Double(item.quantity) * item.price, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                }
            }
            
            Divider()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
