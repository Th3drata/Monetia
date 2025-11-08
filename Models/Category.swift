import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, colorHex: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // Default categories
    static let food = Category(name: "food", icon: "fork.knife", colorHex: "#FF6B6B", isDefault: true)
    static let housing = Category(name: "housing", icon: "house", colorHex: "#4ECDC4", isDefault: true)
    static let transportation = Category(name: "transportation", icon: "car", colorHex: "#45B7D1", isDefault: true)
    static let entertainment = Category(name: "entertainment", icon: "tv", colorHex: "#FFA07A", isDefault: true)
    static let utilities = Category(name: "utilities", icon: "bolt", colorHex: "#98D8C8", isDefault: true)
    static let healthcare = Category(name: "healthcare", icon: "cross.case", colorHex: "#F7B731", isDefault: true)
    static let shopping = Category(name: "shopping", icon: "bag", colorHex: "#A29BFE", isDefault: true)
    static let education = Category(name: "education", icon: "book", colorHex: "#6C5CE7", isDefault: true)
    static let salary = Category(name: "salary", icon: "dollarsign.circle", colorHex: "#00B894", isDefault: true)
    static let other = Category(name: "other", icon: "ellipsis.circle", colorHex: "#95A5A6", isDefault: true)
    
    static let defaultCategories: [Category] = [
        .food, .housing, .transportation, .entertainment, 
        .utilities, .healthcare, .shopping, .education, .salary, .other
    ]
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
