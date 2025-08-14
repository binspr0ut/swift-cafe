import SwiftUI
import SwiftData

struct StaffCallView: View {
    @ObservedObject var viewModel: CustomerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason = StaffCallReason.assistance
    @State private var customReason = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Call Staff")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Table \(viewModel.tableNumber)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Reason Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("What can we help you with?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(StaffCallReason.allCases, id: \.self) { reason in
                            StaffCallReasonCard(
                                reason: reason,
                                isSelected: selectedReason == reason
                            ) {
                                selectedReason = reason
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Custom Reason (if "Other" is selected)
                if selectedReason == .other {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Please specify:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField("Describe your request...", text: $customReason)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Call Button
                Button(action: {
                    callStaff()
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Call Staff")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.orange)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Staff Called", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("A staff member will be with you shortly.")
            }
        }
    }
    
    private func callStaff() {
        let reason = selectedReason == .other ? customReason : selectedReason.displayName
        viewModel.callStaff(reason: reason)
        showingConfirmation = true
    }
}

struct StaffCallReasonCard: View {
    let reason: StaffCallReason
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: reason.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .orange)
                
                Text(reason.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StaffCallView(viewModel: CustomerViewModel(
        modelContext: ModelContext(try! ModelContainer(for: Order.self, MenuItem.self, CafeSettings.self)),
        tableNumber: 1
    ))
}
