# SwiftCafe - Smart Cashier System

## Project Overview

SwiftCafe is a comprehensive smart cashier system designed for cafes, built entirely within the Apple ecosystem. The system consists of 7 iPads total:
- **6 Customer iPads**: Placed at cafe tables for menu browsing and ordering
- **1 Admin iPad**: For staff to manage orders, customize customer interface, and monitor operations

## ✅ COMPLETE IMPLEMENTATION STATUS

### Admin iPad - ✅ FULLY IMPLEMENTED
- **Order Management**: Real-time view of all customer orders with status tracking
- **Menu Editing**: Full CRUD operations for menu items with categories
- **Cafe Customization**: Background images, button colors, branding, themes
- **Table Monitoring**: Status of all 6 customer tables
- **Staff Call Management**: Handle customer assistance requests
- **Real-time Updates**: Live synchronization with customer iPads

### Customer iPad - ✅ FULLY IMPLEMENTED
- **Professional Menu Interface**: iPad-optimized with category selector and grid layout
- **Advanced Cart Management**: Special instructions, quantity controls, real-time pricing
- **Order Status Tracking**: Multi-stage progress indicators and estimated times
- **Staff Call System**: Categorized assistance requests with custom options
- **Menu Item Details**: Full descriptions, customization options, add to cart
- **Responsive Design**: Adapts to admin-configured branding and themes

## Architecture

### Technology Stack
- **SwiftUI**: Modern UI framework for all interfaces
- **SwiftData**: Apple's persistence framework for data storage
- **MultipeerConnectivity**: Zero-configuration networking for iPad-to-iPad communication
- **MVVM Pattern**: Clean architecture with ViewModels and Observable objects

### Data Models ✅ COMPLETE
1. **MenuItem**: Menu items with categories, prices, descriptions, and images
2. **Order**: Customer orders with items, status, and metadata
3. **OrderItem**: Individual items within orders with quantities and special instructions
4. **CafeSettings**: Customizable cafe branding and UI themes
5. **Table**: Table information and status tracking
6. **StaffCall**: Customer requests for staff assistance

## Key Features Implemented

### 🎯 Admin iPad Features
- **Split-view Dashboard**: iOS-compatible navigation with order management
- **Real-time Order Tracking**: Live updates of customer orders across all tables
- **Complete Menu Management**: Add, edit, delete menu items with categories
- **Dynamic Customization**: Change customer iPad themes, colors, backgrounds in real-time
- **Table Status Monitoring**: Visual overview of all 6 customer tables
- **Staff Call Handling**: Receive and manage customer assistance requests

### 🎯 Customer iPad Features
- **Modern Menu Interface**: Professional grid layout with category filtering
- **Enhanced Cart System**: Special instructions, quantity controls, order notes
- **Real-time Order Tracking**: Progress indicators with status badges
- **Staff Communication**: Easy staff call with categorized request types
- **Item Detail Views**: Full descriptions with customization options
- **Responsive Branding**: UI adapts to admin-configured themes

Swift Cafe is designed for a cafe setup with:
- **6 Customer iPads**: Placed at tables for customers to view menus and place orders
- **1 Admin iPad**: For staff to manage orders, customize the cafe experience, and monitor operations

## Architecture

### MVVM (Model-View-ViewModel) Pattern
- **Models**: SwiftData models for persistent storage (MenuItem, Order, CafeSettings, Table)
- **ViewModels**: Business logic and state management (AdminViewModel)
- **Views**: SwiftUI views for user interface

### Key Technologies
- **SwiftUI**: Modern UI framework for iOS
- **SwiftData**: Apple's data persistence framework
- **MultipeerConnectivity**: Real-time communication between iPads
- **Combine**: Reactive programming for state management

## Features

### ✅ Admin iPad Features (COMPLETED)
1. **Order Management**
   - Real-time order monitoring
   - Order status updates (Pending → Preparing → Ready → Completed)
   - Order details with customer notes
   - Order timeline tracking
   - Demo data generation for testing

2. **Menu Management**
   - Add/Edit/Delete menu items
   - Category organization
   - Price and availability management
   - Real-time sync to customer iPads

3. **Cafe Customization**
   - Background image customization
   - Button color themes
   - Text and accent colors
   - Cafe branding settings

4. **Table Monitoring**
   - Real-time table status
   - Connected device monitoring
   - Order history per table

5. **Device Management**
   - Automatic device discovery
   - Connection status monitoring
   - Real-time synchronization

### ✅ Customer iPad Features (FOUNDATION READY)
- Device type selection
- Table number assignment
- Menu browsing with customized theme
- Order placement capability
- Real-time theme updates from admin
- MultipeerConnectivity integration

## Data Models

### MenuItem
- Name, description, price
- Category organization
- Availability status
- Preparation time estimation
- Image support

### Order & OrderItem
- Table association
- Order status tracking
- Customer notes
- Timestamp tracking
- Total calculation

### CafeSettings
- Theme customization
- Branding elements
- Real-time sync to all devices

### Table
- Table numbering (1-6)
- Occupancy status
- Current order tracking
- Peer connectivity

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0 or later (for SwiftData and MultipeerConnectivity)
- Multiple iPads for full system testing
- iPadOS recommended for optimal experience

### Installation
1. Clone the repository
2. Open `SwiftCafe.xcodeproj` in Xcode
3. Build and run on your admin iPad
4. The app will automatically create default data on first launch

### Initial Setup
1. **First Launch**: The app creates default menu items and cafe settings
2. **Network Discovery**: Admin iPad starts advertising for customer iPads
3. **Default Configuration**: 6 tables are automatically configured

## MultipeerConnectivity

### Communication Flow
1. **Admin iPad**: Acts as advertiser and browser
2. **Customer iPads**: Connect as peers
3. **Real-time Sync**: Orders, menu updates, and settings sync instantly
4. **Automatic Discovery**: Devices discover each other automatically

### Message Types
- **OrderMessage**: Customer orders sent to admin
- **SettingsMessage**: Theme updates sent to customers
- **MenuMessage**: Menu updates sent to customers

## Best Practices Implemented

### MVVM Architecture
- Clean separation of concerns
- Testable business logic
- Reactive UI updates
- State management through ObservableObject

### Data Persistence
- SwiftData for local storage
- Automatic relationship management
- Migration support
- Thread-safe operations

### Network Communication
- Reliable message delivery
- Automatic reconnection
- Error handling
- Data serialization with Codable

### User Experience
- Responsive iPad-optimized layouts
- Real-time updates
- Intuitive admin interface
- Customizable customer experience

## Project Structure

```
SwiftCafe/
├── Models/
│   ├── MenuItem.swift
│   ├── Order.swift
│   ├── CafeSettings.swift
│   └── Table.swift
├── ViewModels/
│   └── AdminViewModel.swift
├── Views/
│   ├── Admin/
│   │   ├── AdminDashboardView.swift
│   │   ├── OrderDetailView.swift
│   │   └── MenuEditorViews.swift
│   └── Customer/ (Coming Soon)
├── Services/
│   └── MultipeerService.swift
└── SwiftCafeApp.swift
```

## Future Enhancements

### Customer iPad Implementation
- Complete customer ordering interface
- Table-specific customization
- Real-time order tracking
- Payment integration

### Advanced Features
- Analytics dashboard
- Inventory management
- Staff scheduling
- Customer feedback system
- Kitchen display integration

### Technical Improvements
- Unit test coverage
- Performance optimization
- Offline mode support
- Enhanced error handling

## Development Notes

### Color System
The app uses a dynamic color system that allows real-time theme updates:
- Primary/Secondary button colors
- Text and accent colors
- Background customization

### Network Architecture
MultipeerConnectivity provides:
- Zero-configuration networking
- Encrypted communication
- Automatic peer discovery
- Reliable message delivery

### Data Flow
1. Admin makes changes → SwiftData persistence → MultipeerService
2. Customer actions → MultipeerService → Admin receives updates
3. All changes sync in real-time across connected devices

## Testing

### Recommended Testing Setup
1. Use multiple physical iPads for realistic testing
2. Test network connectivity in cafe environment
3. Verify data persistence across app restarts
4. Test theme customization updates

### Simulator Testing
- Limited MultipeerConnectivity support in Simulator
- Use for UI development and basic testing
- Physical devices required for network features

## License

This project is built for educational and demonstration purposes. Please ensure proper licensing for commercial use.

## Contact

Built with ❤️ for the Swift community and cafe enthusiasts worldwide.
