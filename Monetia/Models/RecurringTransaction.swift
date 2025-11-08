import Foundation

enum RecurringFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var localizedName: String {
        switch self {
        case .daily: return NSLocalizedString("recurring_daily", comment: "")
        case .weekly: return NSLocalizedString("recurring_weekly", comment: "")
        case .monthly: return NSLocalizedString("recurring_monthly", comment: "")
        case .yearly: return NSLocalizedString("recurring_yearly", comment: "")
        }
    }
    
    func nextDate(after date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

struct RecurringTransaction: Identifiable, Codable {
    var id: UUID
    var amount: Decimal
    var type: TransactionType
    var category: Category
    var accountId: UUID
    var toAccountId: UUID?
    var notes: String?
    var frequency: RecurringFrequency
    var nextOccurrence: Date
    var endDate: Date?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         amount: Decimal,
         type: TransactionType,
         category: Category,
         accountId: UUID,
         toAccountId: UUID? = nil,
         notes: String? = nil,
         frequency: RecurringFrequency,
         startDate: Date = Date(),
         endDate: Date? = nil) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.accountId = accountId
        self.toAccountId = toAccountId
        self.notes = notes
        self.frequency = frequency
        self.nextOccurrence = startDate
        self.endDate = endDate
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func shouldGenerate() -> Bool {
        guard isActive else { return false }
        guard nextOccurrence <= Date() else { return false }
        
        if let endDate = endDate, Date() > endDate {
            return false
        }
        
        return true
    }
    
    mutating func updateNextOccurrence() {
        nextOccurrence = frequency.nextDate(after: nextOccurrence)
        updatedAt = Date()
    }
    
    func toTransaction() -> Transaction {
        return Transaction(
            amount: amount,
            type: type,
            category: category,
            accountId: accountId,
            date: Date(),
            notes: notes,
            toAccountId: toAccountId
        )
    }
}
