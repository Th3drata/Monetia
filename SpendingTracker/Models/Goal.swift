import Foundation
import SwiftUI

struct Goal: Identifiable, Codable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         icon: String = "star",
         colorHex: String = "#007AFF",
         targetAmount: Decimal,
         currentAmount: Decimal = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var color: Color {
        return Color(hex: colorHex) ?? .blue
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        let progressValue = Double(truncating: (currentAmount / targetAmount) as NSDecimalNumber)
        return min(progressValue, 1.0)
    }
    
    var remaining: Decimal {
        return max(targetAmount - currentAmount, 0)
    }
    
    var isCompleted: Bool {
        return currentAmount >= targetAmount
    }
}
