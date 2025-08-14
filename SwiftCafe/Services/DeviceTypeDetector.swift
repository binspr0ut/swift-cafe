//
//  DeviceTypeDetector.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import UIKit

enum DeviceType {
    case admin
    case customer
}

class DeviceTypeDetector: ObservableObject {
    @Published var deviceType: DeviceType = .admin
    
    init() {
        detectDeviceType()
    }
    
    private func detectDeviceType() {
        // For demonstration, we'll use device name detection
        // In a real app, you might use device configuration or user selection
        let deviceName = UIDevice.current.name.lowercased()
        
        if deviceName.contains("admin") || deviceName.contains("manager") || deviceName.contains("staff") {
            deviceType = .admin
        } else {
            deviceType = .customer
        }
        
        // For development purposes, you can manually set this
        // deviceType = .admin // Force admin mode for testing
    }
    
    func setDeviceType(_ type: DeviceType) {
        deviceType = type
    }
}
