//
//  PermissionGuideView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct PermissionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    permissionsSection
                    troubleshootingSection
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("Network Permissions")
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
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wifi.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Network Permissions Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Swift Cafe needs permissions to connect iPads")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Your 7-iPad cafe system uses MultipeerConnectivity to create a seamless network between all devices. iOS requires explicit permission for this functionality.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Permissions Section
    @ViewBuilder
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Required Permissions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                permissionRow(
                    icon: "wifi",
                    title: "Local Network",
                    description: "Allows iPads to discover each other on the same WiFi network"
                )
                
                permissionRow(
                    icon: "dot.radiowaves.left.and.right",
                    title: "Bluetooth",
                    description: "Enables device discovery and initial connection handshake"
                )
                
                permissionRow(
                    icon: "bonjour",
                    title: "Bonjour Services", 
                    description: "Registers the cafe service for automatic device discovery"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func permissionRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Troubleshooting Section
    @ViewBuilder
    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When Permissions Are Requested")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                stepRow(
                    number: "1",
                    title: "First Launch",
                    description: "iOS will show permission dialogs when you first start the cafe services"
                )
                
                stepRow(
                    number: "2", 
                    title: "Local Network Dialog",
                    description: "Tap 'Allow' to let the app find devices on your local network"
                )
                
                stepRow(
                    number: "3",
                    title: "Bluetooth Permission",
                    description: "Grant Bluetooth access for device discovery"
                )
                
                stepRow(
                    number: "4",
                    title: "Connection Success",
                    description: "Admin iPad will start advertising, customer iPads will connect"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
    
    @ViewBuilder
    private func stepRow(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 24, height: 24)
                .overlay(
                    Text(number)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Settings Section
    @ViewBuilder
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("If Permissions Were Denied")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("You can manually enable permissions in iOS Settings:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                settingsPath("Settings → Privacy & Security → Local Network → Swift Cafe → ON")
                settingsPath("Settings → Privacy & Security → Bluetooth → Swift Cafe → ON")
            }
            
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func settingsPath(_ path: String) -> some View {
        HStack {
            Image(systemName: "gear")
                .foregroundColor(.gray)
            
            Text(path)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(4)
            
            Spacer()
        }
    }
}

#Preview {
    PermissionGuideView()
}
