//
//  OrderStatusView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct OrderStatusView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    mainContentView
                }
                .padding()
            }
            .navigationTitle("Order Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadActiveOrder()
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 8) {
            if let settings = viewModel.cafeSettings {
                Text(settings.cafeName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(settings.textUIColor)
            }
            
            Text("Table \(viewModel.tableNumber)")
                .font(.title3)
                .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContentView: some View {
        if let activeOrder = viewModel.activeOrder {
            activeOrderView(activeOrder)
        } else {
            noActiveOrderView
        }
    }
    
    // MARK: - Active Order View
    @ViewBuilder
    private func activeOrderView(_ activeOrder: Order) -> some View {
        VStack(spacing: 24) {
            orderStatusCard(activeOrder)
            OrderProgressView(status: activeOrder.status, settings: viewModel.cafeSettings)
            
            if activeOrder.status != .completed && activeOrder.status != .cancelled {
                estimatedTimeView(activeOrder)
            }
            
            actionButtonsView(activeOrder)
        }
    }
    
    // MARK: - No Active Order View
    @ViewBuilder
    private var noActiveOrderView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("No Active Orders")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You don't have any orders in progress right now.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Browse Menu") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle(settings: viewModel.cafeSettings))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Order Status Card
    @ViewBuilder
    private func orderStatusCard(_ activeOrder: Order) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(activeOrder.id.uuidString.prefix(8))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Placed at \(formattedTime(activeOrder.dateCreated))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: activeOrder.status, settings: viewModel.cafeSettings)
            }
            
            Divider()
            
            orderItemsList(activeOrder)
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("$\(activeOrder.totalAmount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Order Items List
    @ViewBuilder
    private func orderItemsList(_ activeOrder: Order) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Items")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ForEach(activeOrder.items, id: \.id) { item in
                HStack {
                    Text("\(item.quantity)×")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline)
                        
                        if let instructions = item.specialInstructions, !instructions.isEmpty {
                            Text("Note: \(instructions)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Spacer()
                    
                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Estimated Time View
    @ViewBuilder
    private func estimatedTimeView(_ activeOrder: Order) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(viewModel.cafeSettings?.accentUIColor ?? .orange)
                Text("Estimated completion time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(estimatedCompletionTime(for: activeOrder))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.cafeSettings?.textUIColor ?? .primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private func actionButtonsView(_ activeOrder: Order) -> some View {
        VStack(spacing: 12) {
            if activeOrder.status == .ready {
                Button("Order Ready for Pickup!") {
                    // Could notify that customer is coming
                }
                .buttonStyle(PrimaryButtonStyle(settings: viewModel.cafeSettings))
            }
            
            Button("Call Staff") {
                viewModel.callStaff(reason: "Order inquiry")
            }
            .buttonStyle(SecondaryButtonStyle(settings: viewModel.cafeSettings))
        }
    }
    
    // MARK: - Helper Functions
    private func estimatedCompletionTime(for order: Order) -> String {
        let totalPrepTime = order.items.reduce(0) { total, item in
            total + (10 * item.quantity)
        }
        
        let estimatedCompletion = order.dateCreated.addingTimeInterval(TimeInterval(totalPrepTime * 60))
        
        if estimatedCompletion > Date() {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: estimatedCompletion)
        } else {
            return "Any moment now"
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct StatusBadge: View {
    let status: OrderStatus
    let settings: CafeSettings?
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .preparing: return .blue
        case .ready: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

struct OrderProgressView: View {
    let status: OrderStatus
    let settings: CafeSettings?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ProgressStep(
                    title: "Order Received",
                    description: "Your order has been received",
                    isCompleted: true,
                    isActive: status == .pending,
                    settings: settings
                )
                
                ProgressStep(
                    title: "Preparing",
                    description: "Your order is being prepared",
                    isCompleted: [.preparing, .ready, .completed].contains(status),
                    isActive: status == .preparing,
                    settings: settings
                )
                
                ProgressStep(
                    title: "Ready",
                    description: "Your order is ready for pickup",
                    isCompleted: [.ready, .completed].contains(status),
                    isActive: status == .ready,
                    settings: settings
                )
                
                ProgressStep(
                    title: "Completed",
                    description: "Enjoy your order!",
                    isCompleted: status == .completed,
                    isActive: false,
                    settings: settings
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ProgressStep: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isActive: Bool
    let settings: CafeSettings?
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .medium)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isActive {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private var circleColor: Color {
        if isCompleted {
            return settings?.primaryButtonUIColor ?? .blue
        } else if isActive {
            return settings?.accentUIColor ?? .orange
        } else {
            return Color(.systemGray4)
        }
    }
}
