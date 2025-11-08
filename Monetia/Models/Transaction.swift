import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID
    var amount: Decimal
    var type: TransactionType
    var category: Category
    var accountId: UUID
    var date: Date
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // For transfers between accounts
    var toAccountId: UUID?
    
    init(id: UUID = UUID(), 
         amount: Decimal, 
         type: TransactionType, 
         category: Category, 
         accountId: UUID, 
         date: Date = Date(), 
         notes: String? = nil,
         toAccountId: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.accountId = accountId
        self.date = date
        self.notes = notes
        self.toAccountId = toAccountId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var isTransfer: Bool {
        return toAccountId != nil
    }
}

enum TransactionType: String, Codable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
    
    var localizedName: String {
        switch self {
        case .income: return NSLocalizedString("transaction_type_income", comment: "")
        case .expense: return NSLocalizedString("transaction_type_expense", comment: "")
        case .transfer: return NSLocalizedString("transaction_type_transfer", comment: "")
        }
    }
}
