# 🏪 Swift Cafe - 7-iPad Setup Guide

## 📋 **Quick Start Checklist**

### **Pre-Setup Requirements**
- [ ] 7 iPads (iOS 15.0 or later)
- [ ] All iPads connected to the same WiFi network
- [ ] SwiftCafe app installed on all devices
- [ ] Bluetooth enabled on all devices

---

## 🎯 **Device Configuration**

### **1️⃣ Admin iPad Setup**
1. **Launch** SwiftCafe app
2. **Select** "Admin iPad" in device setup
3. **Verify** "Advertising" status shows as Active
4. **Navigate** to "Connections" tab to monitor devices

### **2️⃣ Customer iPad Setup (Repeat for Tables 1-6)**
1. **Launch** SwiftCafe app on customer iPad
2. **Select** "Customer iPad" in device setup
3. **Choose** table number (1, 2, 3, 4, 5, or 6)
4. **Wait** for automatic connection to admin device

---

## 🔗 **Connection Process**

### **Automatic Discovery**
The system uses **MultipeerConnectivity** for zero-configuration networking:

```
Admin iPad → Starts Advertising → Customer iPads Discover → Auto-Connect
```

### **Connection Status Monitoring**
- **Admin Dashboard**: Check "Connections" tab
- **Progress Bar**: Shows X/6 devices connected
- **Device List**: Displays all connected customer iPads
- **Real-time Updates**: Status updates automatically

---

## 🛠️ **Troubleshooting**

### **Connection Issues**
1. **Ensure Same Network**: All devices on same WiFi
2. **Restart Advertising**: Use button in Connections tab
3. **Bluetooth Check**: Enable Bluetooth on all devices
4. **App Restart**: Close and reopen app if needed

### **Common Solutions**
- **Red Status**: No connections → Check network/restart advertising
- **Orange Status**: Partial connections → Wait or restart unconnected devices
- **Green Status**: All connected → System ready!

### **Reset Options**
- **Restart Advertising**: Admin Connections tab → "Restart Advertising"
- **Device Reset**: Close app → Reopen → Reconfigure device type
- **Full Reset**: Force quit app on all devices → Start setup again

---

## ✅ **Verification Steps**

### **Admin iPad Checklist**
- [ ] Shows "All customer iPads connected" (6/6)
- [ ] Green status indicators in Connections tab
- [ ] Can see all 6 devices in connected list
- [ ] Orders tab shows real-time updates

### **Customer iPad Checklist**
- [ ] Shows correct table number
- [ ] Menu loads successfully
- [ ] Can add items to cart
- [ ] Orders sync to admin device

### **System Integration Test**
1. **Place Test Order**: Use any customer iPad
2. **Verify Admin Receives**: Check admin Orders tab
3. **Update Order Status**: Mark as preparing/ready on admin
4. **Confirm Updates**: Check customer Order Status view

---

## 🚀 **Deployment Tips**

### **Physical Setup**
- **Admin iPad**: Central location for staff access
- **Customer iPads**: Table stands with power/charging
- **Network**: Strong WiFi coverage throughout cafe
- **Backup**: Keep one additional iPad as backup

### **Staff Training**
- **Admin Operations**: Order management, status updates
- **Troubleshooting**: Connection restart procedures
- **Customer Assistance**: Help with ordering process

### **Maintenance**
- **Daily**: Check all connections at opening
- **Weekly**: Restart all devices for optimal performance
- **Monthly**: Update app if new versions available

---

## 📱 **System Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                     📱 Admin iPad                          │
│                  (Order Management)                        │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │    Orders       │  │   Connections   │                 │
│  │   Dashboard     │  │    Monitor      │                 │
│  └─────────────────┘  └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                              │
                    ╭─────────┴─────────╮
                    │  MultipeerService │
                    │   (Auto-Discovery) │
                    ╰─────────┬─────────╯
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │                         │                         │
   📱                        📱                        📱
Table 1                   Table 2                   Table 3
Customer                  Customer                  Customer
 iPad                      iPad                      iPad
    │                         │                         │
   📱                        📱                        📱
Table 4                   Table 5                   Table 6
Customer                  Customer                  Customer
 iPad                      iPad                      iPad
```

---

## 🎉 **Success Indicators**

### **✅ System Ready When:**
- Admin shows 6/6 connections
- All customer iPads show menu
- Test orders flow from customer → admin
- Real-time status updates work
- Staff can manage orders efficiently

### **🔧 Need Help When:**
- Connections show less than 6/6
- Customer iPads can't load menu
- Orders don't appear on admin
- Status updates don't sync
- Frequent disconnections occur

---

*Your Swift Cafe 7-iPad Smart Cashier System is designed for seamless operation with minimal technical intervention. The MultipeerConnectivity framework handles all networking automatically!*
