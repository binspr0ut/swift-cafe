import Foundation
import SwiftData

@Model
final class StaffCall {
    var id: UUID
    var tableNumber: Int
    var reason: String
    var timestamp: Date
    var isResolved: Bool
    
    init(tableNumber: Int, reason: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.tableNumber = tableNumber
        self.reason = reason
        self.timestamp = timestamp
        self.isResolved = false
    }
}

enum StaffCallReason: String, CaseIterable {
    case assistance = "Need Assistance"
    case orderIssue = "Order Issue"
    case billing = "Billing Question"
    case cleanup = "Table Cleanup"
    case refill = "Refill Request"
    case other = "Other"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .assistance:
            return "hand.raised.fill"
        case .orderIssue:
            return "exclamationmark.triangle.fill"
        case .billing:
            return "creditcard.fill"
        case .cleanup:
            return "trash.fill"
        case .refill:
            return "cup.and.saucer.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}
