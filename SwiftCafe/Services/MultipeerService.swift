//
//  MultipeerService.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

protocol MultipeerServiceDelegate: AnyObject {
    func didReceiveOrder(_ order: Order)
    func didReceiveSettingsUpdate(_ settings: CafeSettings)
    func didReceiveMenuUpdate(_ menu: [MenuItem])
    func peerDidConnect(_ peerID: MCPeerID)
    func peerDidDisconnect(_ peerID: MCPeerID)
}

class MultipeerService: NSObject, ObservableObject {
    private let serviceType = "swift-cafe"
    private let myPeerID: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    
    weak var delegate: MultipeerServiceDelegate?
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    deinit {
        stopAdvertising()
        stopBrowsing()
    }
    
    func startAdvertising() {
        serviceAdvertiser.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopAdvertising() {
        serviceAdvertiser.stopAdvertisingPeer()
        isAdvertising = false
    }
    
    func startBrowsing() {
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
    }
    
    func stopBrowsing() {
        serviceBrowser.stopBrowsingForPeers()
        isBrowsing = false
    }
    
    func sendOrder(_ order: Order, to peer: MCPeerID? = nil) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let orderData = OrderData(
                id: order.id,
                tableNumber: order.tableNumber,
                items: order.items.map { item in
                    OrderItemData(
                        id: item.id,
                        menuItemId: item.menuItemId,
                        name: item.name,
                        price: item.price,
                        quantity: item.quantity,
                        specialInstructions: item.specialInstructions
                    )
                },
                totalAmount: order.totalAmount,
                status: order.status.rawValue,
                dateCreated: order.dateCreated,
                dateCompleted: order.dateCompleted,
                customerNotes: order.customerNotes
            )
            
            let data = try encoder.encode(OrderMessage(orderData: orderData))
            let peers = peer != nil ? [peer!] : session.connectedPeers
            
            if !peers.isEmpty {
                try session.send(data, toPeers: peers, with: .reliable)
            }
        } catch {
            print("Error sending order: \(error)")
        }
    }
    
    func sendSettingsUpdate(_ settings: CafeSettings) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let settingsData = SettingsData(
                id: settings.id,
                backgroundImageName: settings.backgroundImageName,
                primaryButtonColor: settings.primaryButtonColor,
                secondaryButtonColor: settings.secondaryButtonColor,
                textColor: settings.textColor,
                accentColor: settings.accentColor,
                cafeName: settings.cafeName,
                logoImageName: settings.logoImageName
            )
            
            let data = try encoder.encode(SettingsMessage(settingsData: settingsData))
            
            if !session.connectedPeers.isEmpty {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            print("Error sending settings: \(error)")
        }
    }
    
    func sendMenuUpdate(_ menu: [MenuItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let menuData = menu.map { item in
                MenuData(
                    id: item.id,
                    name: item.name,
                    menuDescription: item.menuDescription,
                    price: item.price,
                    category: item.category,
                    imageName: item.imageName,
                    isAvailable: item.isAvailable,
                    preparationTime: item.preparationTime
                )
            }
            
            let data = try encoder.encode(MenuMessage(menuData: menuData))
            
            if !session.connectedPeers.isEmpty {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
        } catch {
            print("Error sending menu: \(error)")
        }
    }
}

// MARK: - MCSessionDelegate
extension MultipeerService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPeers.append(peerID)
                self.delegate?.peerDidConnect(peerID)
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                self.delegate?.peerDidDisconnect(peerID)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            if let orderMessage = try? decoder.decode(OrderMessage.self, from: data) {
                // Convert OrderData back to Order model
                let orderItems = orderMessage.orderData.items.map { itemData in
                    let orderItem = OrderItem(
                        menuItemId: itemData.menuItemId,
                        name: itemData.name,
                        price: itemData.price,
                        quantity: itemData.quantity,
                        specialInstructions: itemData.specialInstructions
                    )
                    orderItem.id = itemData.id
                    return orderItem
                }
                
                let order = Order(
                    tableNumber: orderMessage.orderData.tableNumber,
                    orderItems: orderItems,
                    customerNotes: orderMessage.orderData.customerNotes
                )
                order.id = orderMessage.orderData.id
                order.totalAmount = orderMessage.orderData.totalAmount
                order.status = OrderStatus(rawValue: orderMessage.orderData.status) ?? .pending
                order.dateCreated = orderMessage.orderData.dateCreated
                order.dateCompleted = orderMessage.orderData.dateCompleted
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveOrder(order)
                }
            } else if let settingsMessage = try? decoder.decode(SettingsMessage.self, from: data) {
                // Convert SettingsData back to CafeSettings model
                let settings = CafeSettings(
                    cafeName: settingsMessage.settingsData.cafeName,
                    backgroundImageName: settingsMessage.settingsData.backgroundImageName,
                    primaryButtonColor: settingsMessage.settingsData.primaryButtonColor,
                    secondaryButtonColor: settingsMessage.settingsData.secondaryButtonColor,
                    textColor: settingsMessage.settingsData.textColor,
                    accentColor: settingsMessage.settingsData.accentColor,
                    logoImageName: settingsMessage.settingsData.logoImageName
                )
                settings.id = settingsMessage.settingsData.id
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveSettingsUpdate(settings)
                }
            } else if let menuMessage = try? decoder.decode(MenuMessage.self, from: data) {
                // Convert MenuData back to MenuItem models
                let menuItems = menuMessage.menuData.map { menuData in
                    let menuItem = MenuItem(
                        name: menuData.name,
                        description: menuData.menuDescription,
                        price: menuData.price,
                        category: menuData.category,
                        imageName: menuData.imageName,
                        isAvailable: menuData.isAvailable,
                        preparationTime: menuData.preparationTime
                    )
                    menuItem.id = menuData.id
                    return menuItem
                }
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveMenuUpdate(menuItems)
                }
            }
        } catch {
            print("Error decoding message: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

// MARK: - Message Models
struct OrderMessage: Codable {
    let orderData: OrderData
    let type = "order"
}

struct SettingsMessage: Codable {
    let settingsData: SettingsData
    let type = "settings"
}

struct MenuMessage: Codable {
    let menuData: [MenuData]
    let type = "menu"
}

// Codable data transfer objects
struct OrderData: Codable {
    let id: UUID
    let tableNumber: Int
    let items: [OrderItemData]
    let totalAmount: Double
    let status: String
    let dateCreated: Date
    let dateCompleted: Date?
    let customerNotes: String?
}

struct OrderItemData: Codable {
    let id: UUID
    let menuItemId: UUID
    let name: String
    let price: Double
    let quantity: Int
    let specialInstructions: String?
}

struct MenuData: Codable {
    let id: UUID
    let name: String
    let menuDescription: String
    let price: Double
    let category: String
    let imageName: String?
    let isAvailable: Bool
    let preparationTime: Int
}

struct SettingsData: Codable {
    let id: UUID
    let backgroundImageName: String?
    let primaryButtonColor: String
    let secondaryButtonColor: String
    let textColor: String
    let accentColor: String
    let cafeName: String
    let logoImageName: String?
}
