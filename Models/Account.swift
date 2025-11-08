import Foundation

struct Account: Identifiable, Codable {
    var id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, type: AccountType, balance: Decimal = 0, currency: String = "EUR") {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.currency = currency
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum AccountType: String, Codable, CaseIterable {
    case checking = "checking"
    case card = "card"
    case cash = "cash"
    case savings = "savings"
    
    var localizedName: String {
        switch self {
        case .checking: return NSLocalizedString("account_type_checking", comment: "")
        case .card: return NSLocalizedString("account_type_card", comment: "")
        case .cash: return NSLocalizedString("account_type_cash", comment: "")
        case .savings: return NSLocalizedString("account_type_savings", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .checking: return "building.columns"
        case .card: return "creditcard"
        case .cash: return "banknote"
        case .savings: return "dollarsign.circle"
        }
    }
}
