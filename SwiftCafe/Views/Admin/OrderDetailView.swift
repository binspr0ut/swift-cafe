//
//  OrderDetailView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Order Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Table \(order.tableNumber)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(order.status.rawValue)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor.opacity(0.2))
                                .foregroundColor(statusColor)
                                .cornerRadius(8)
                        }
                        
                        HStack {
                            Text("Order #\(order.id.uuidString.prefix(8))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("$\(order.totalAmount, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Ordered: \(order.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Order Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items")
                            .font(.headline)
                        
                        ForEach(order.items, id: \.id) { item in
                            OrderItemRow(item: item)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Customer Notes
                    if let notes = order.customerNotes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Customer Notes")
                                .font(.headline)
                            
                            Text(notes)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Order Timeline
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Timeline")
                            .font(.headline)
                        
                        OrderTimelineView(order: order)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if order.status == .pending {
                            Button("Start Preparing") {
                                viewModel.updateOrderStatus(order, to: .preparing)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        } else if order.status == .preparing {
                            Button("Mark as Ready") {
                                viewModel.updateOrderStatus(order, to: .ready)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .frame(maxWidth: .infinity)
                        } else if order.status == .ready {
                            Button("Complete Order") {
                                viewModel.updateOrderStatus(order, to: .completed)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .frame(maxWidth: .infinity)
                        }
                        
                        if order.status != .cancelled && order.status != .completed {
                            Button("Cancel Order") {
                                viewModel.updateOrderStatus(order, to: .cancelled)
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

struct OrderItemRow: View {
    let item: OrderItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let instructions = item.specialInstructions, !instructions.isEmpty {
                    Text("Note: \(instructions)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("×\(item.quantity)")
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct OrderTimelineView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TimelineItem(
                title: "Order Placed",
                time: order.dateCreated,
                isCompleted: true,
                isActive: order.status == .pending
            )
            
            TimelineItem(
                title: "Preparing",
                time: nil,
                isCompleted: [.preparing, .ready, .completed].contains(order.status),
                isActive: order.status == .preparing
            )
            
            TimelineItem(
                title: "Ready for Pickup",
                time: nil,
                isCompleted: [.ready, .completed].contains(order.status),
                isActive: order.status == .ready
            )
            
            TimelineItem(
                title: "Completed",
                time: order.dateCompleted,
                isCompleted: order.status == .completed,
                isActive: false
            )
        }
    }
}

struct TimelineItem: View {
    let title: String
    let time: Date?
    let isCompleted: Bool
    let isActive: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isCompleted ? .green : (isActive ? .blue : .gray))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                if let time = time {
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}
