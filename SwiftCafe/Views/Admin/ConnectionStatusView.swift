//
//  ConnectionStatusView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI
import MultipeerConnectivity

struct ConnectionStatusView: View {
    @ObservedObject var multipeerService: MultipeerService
    @State private var showingConnectionDetails = false
    @State private var showingPermissionGuide = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Permission Warning
            if !multipeerService.permissionsGranted {
                permissionWarningCard
            }
            
            // Error Display
            if let error = multipeerService.lastError {
                errorCard(error)
            }
            
            // Connection Overview
            connectionOverviewCard
            
            // Connected Devices List
            if !multipeerService.connectedPeers.isEmpty {
                connectedDevicesList
            }
            
            // Connection Controls
            connectionControlsCard
            
            // Network Status
            networkStatusCard
        }
        .padding()
        .sheet(isPresented: $showingConnectionDetails) {
            ConnectionDetailsView(multipeerService: multipeerService)
        }
        .sheet(isPresented: $showingPermissionGuide) {
            PermissionGuideView()
        }
    }
    
    // MARK: - Permission Warning
    @ViewBuilder
    private var permissionWarningCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wifi.exclamationmark")
                    .foregroundColor(.orange)
                
                Text("Network Permission Required")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text("The app needs permission to use local network and Bluetooth to connect iPads. You should see permission dialogs when starting the service.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Check Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Retry Connection") {
                    multipeerService.forceRestart()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Error Card
    @ViewBuilder
    private func errorCard(_ error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text("Connection Error")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Dismiss") {
                    multipeerService.lastError = nil
                }
                .buttonStyle(.borderless)
                .foregroundColor(.blue)
            }
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Force Restart") {
                multipeerService.forceRestart()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Connection Overview
    @ViewBuilder
    private var connectionOverviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: connectionStatusIcon)
                    .font(.title2)
                    .foregroundColor(connectionStatusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Network Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(connectionStatusText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(multipeerService.connectedPeers.count)/6")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(connectionStatusColor)
            }
            
            // Progress Bar
            ProgressView(value: Double(multipeerService.connectedPeers.count), total: 6.0)
                .progressViewStyle(LinearProgressViewStyle(tint: connectionStatusColor))
                .scaleEffect(y: 2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Connected Devices List
    @ViewBuilder
    private var connectedDevicesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connected Customer iPads")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(multipeerService.connectedPeers, id: \.self) { peer in
                    connectedDeviceCard(peer)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func connectedDeviceCard(_ peer: MCPeerID) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "ipad")
                .font(.title3)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(peer.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Connection Controls
    @ViewBuilder
    private var connectionControlsCard: some View {
        VStack(spacing: 16) {
            Text("Connection Controls")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Restart Services
                    Button(action: {
                        multipeerService.restartServices()
                    }) {
                        Label("Quick Restart", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    
                    // Force Restart
                    Button(action: {
                        multipeerService.forceRestart()
                    }) {
                        Label("Force Restart", systemImage: "power")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
                
                Button("Connection Details") {
                    showingConnectionDetails = true
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                
                Button("Permission Guide") {
                    showingPermissionGuide = true
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Network Status
    @ViewBuilder
    private var networkStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                statusRow("Service Type", value: "cafe")
                statusRow("Permissions", value: multipeerService.permissionsGranted ? "Granted" : "Pending")
                statusRow("Advertising", value: multipeerService.isAdvertising ? "Active" : "Inactive")
                statusRow("Browsing", value: multipeerService.isBrowsing ? "Active" : "Inactive")
                statusRow("Peer ID", value: "Admin Device")
                statusRow("Connection Method", value: "MultipeerConnectivity")
                
                if let error = multipeerService.lastError {
                    statusRow("Last Error", value: "Check error above")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func statusRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Computed Properties
    private var connectionStatusIcon: String {
        switch multipeerService.connectedPeers.count {
        case 0: return "wifi.slash"
        case 1...3: return "wifi"
        case 4...5: return "wifi"
        case 6: return "checkmark.circle.fill"
        default: return "wifi"
        }
    }
    
    private var connectionStatusColor: Color {
        switch multipeerService.connectedPeers.count {
        case 0: return .red
        case 1...3: return .orange
        case 4...5: return .blue
        case 6: return .green
        default: return .gray
        }
    }
    
    private var connectionStatusText: String {
        switch multipeerService.connectedPeers.count {
        case 0: return "No customer iPads connected"
        case 1: return "1 customer iPad connected"
        case 6: return "All customer iPads connected"
        default: return "\(multipeerService.connectedPeers.count) customer iPads connected"
        }
    }
}

struct ConnectionDetailsView: View {
    @ObservedObject var multipeerService: MultipeerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Connection Status") {
                    HStack {
                        Text("Advertising")
                        Spacer()
                        Image(systemName: multipeerService.isAdvertising ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(multipeerService.isAdvertising ? .green : .red)
                    }
                    
                    HStack {
                        Text("Connected Peers")
                        Spacer()
                        Text("\(multipeerService.connectedPeers.count)")
                            .fontWeight(.semibold)
                    }
                }
                
                if !multipeerService.connectedPeers.isEmpty {
                    Section("Connected Devices") {
                        ForEach(multipeerService.connectedPeers, id: \.self) { peer in
                            HStack {
                                Image(systemName: "ipad")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(peer.displayName)
                                        .fontWeight(.medium)
                                    Text("Customer iPad")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                
                Section("Troubleshooting") {
                    Button("Restart All Services") {
                        multipeerService.restartServices()
                    }
                    
                    Button("Disconnect All Peers") {
                        multipeerService.disconnectAllPeers()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Reset Network Stack") {
                        multipeerService.disconnectAllPeers()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            multipeerService.restartServices()
                        }
                    }
                    .foregroundColor(.red)
                }
                
                if let error = multipeerService.lastError {
                    Section("Current Error") {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Connection Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ConnectionStatusView(multipeerService: MultipeerService())
}
