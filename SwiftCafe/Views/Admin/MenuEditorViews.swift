//
//  MenuEditorViews.swift
//  SwiftCafe
//
//  Created by Mahardika Putra Wardhana on 14/08/25.
//

import SwiftUI

struct AddMenuItemView: View {
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = "Coffee"
    @State private var imageName = ""
    @State private var isAvailable = true
    @State private var preparationTime = 10
    
    private let categories = ["Coffee", "Tea", "Food", "Pastry", "Dessert", "Beverage"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Item Name", text: $name)
                    
                    TextField("Description", text: $description)
                        .lineLimit(6)
                    
                    HStack {
                        Text("Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section("Category & Details") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Image Name (optional)", text: $imageName)
                    
                    HStack {
                        Text("Preparation Time")
                        Spacer()
                        Stepper("\(preparationTime) min", value: $preparationTime, in: 1...60)
                    }
                    
                    Toggle("Available", isOn: $isAvailable)
                }
            }
            .navigationTitle("Add Menu Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMenuItem()
                    }
                    .disabled(name.isEmpty || description.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    private func saveMenuItem() {
        guard let priceValue = Double(price) else { return }
        
        let newItem = MenuItem(
            name: name,
            description: description,
            price: priceValue,
            category: category,
            imageName: imageName.isEmpty ? nil : imageName,
            isAvailable: isAvailable,
            preparationTime: preparationTime
        )
        
        viewModel.addMenuItem(newItem)
        dismiss()
    }
}

struct EditMenuItemView: View {
    let item: MenuItem
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var category: String
    @State private var imageName: String
    @State private var isAvailable: Bool
    @State private var preparationTime: Int
    
    private let categories = ["Coffee", "Tea", "Food", "Pastry", "Dessert", "Beverage"]
    
    init(item: MenuItem, viewModel: AdminViewModel) {
        self.item = item
        self.viewModel = viewModel
        
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.menuDescription)
        _price = State(initialValue: String(format: "%.2f", item.price))
        _category = State(initialValue: item.category)
        _imageName = State(initialValue: item.imageName ?? "")
        _isAvailable = State(initialValue: item.isAvailable)
        _preparationTime = State(initialValue: item.preparationTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Item Name", text: $name)
                    
                    TextField("Description", text: $description)
                        .lineLimit(6)
                    
                    HStack {
                        Text("Price")
                        Spacer()
                        Text("$")
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section("Category & Details") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Image Name (optional)", text: $imageName)
                    
                    HStack {
                        Text("Preparation Time")
                        Spacer()
                        Stepper("\(preparationTime) min", value: $preparationTime, in: 1...60)
                    }
                    
                    Toggle("Available", isOn: $isAvailable)
                }
                
                Section {
                    Button("Delete Item", role: .destructive) {
                        viewModel.deleteMenuItem(item)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Menu Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || description.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let priceValue = Double(price) else { return }
        
        item.name = name
        item.menuDescription = description
        item.price = priceValue
        item.category = category
        item.imageName = imageName.isEmpty ? nil : imageName
        item.isAvailable = isAvailable
        item.preparationTime = preparationTime
        
        viewModel.updateMenuItem(item)
        dismiss()
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            CafeCustomizationView(viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
