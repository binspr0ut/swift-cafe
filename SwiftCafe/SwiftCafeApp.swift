//
//  SwiftCafeApp.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftCafeApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MenuItem.self,
            Order.self,
            OrderItem.self,
            CafeSettings.self,
            Table.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
