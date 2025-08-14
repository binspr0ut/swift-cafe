//
//  ContentView.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var deviceDetector = DeviceTypeDetector()
    @State private var selectedTableNumber = 1
    @State private var showingDeviceSelection = false
    
    var body: some View {
        Group {
            switch deviceDetector.deviceType {
            case .admin:
                AdminDashboardView(modelContext: modelContext)
            case .customer:
                CustomerMenuView(modelContext: modelContext, tableNumber: selectedTableNumber)
            }
        }
        .onAppear {
            // For development, show device selection
            showingDeviceSelection = true
        }
        .sheet(isPresented: $showingDeviceSelection) {
            DeviceSetupView(
                deviceDetector: deviceDetector,
                selectedTableNumber: $selectedTableNumber,
                isPresented: $showingDeviceSelection
            )
        }
    }
}

struct DeviceSetupView: View {
    @ObservedObject var deviceDetector: DeviceTypeDetector
    @Binding var selectedTableNumber: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "ipad")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Swift Cafe Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Choose the device type for this iPad")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    Button(action: {
                        deviceDetector.setDeviceType(.admin)
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "person.badge.key")
                                .font(.title2)
                            Text("Admin iPad")
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            deviceDetector.setDeviceType(.customer)
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "person")
                                    .font(.title2)
                                Text("Customer iPad")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        if deviceDetector.deviceType == .customer {
                            VStack {
                                Text("Select Table Number")
                                    .font(.headline)
                                
                                Picker("Table Number", selection: $selectedTableNumber) {
                                    ForEach(1...6, id: \.self) { number in
                                        Text("Table \(number)").tag(number)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Device Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MenuItem.self, Order.self, OrderItem.self, CafeSettings.self, Table.self], inMemory: true)
}
