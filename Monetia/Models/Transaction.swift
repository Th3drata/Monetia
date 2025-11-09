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
    
    // For recurring transactions
    var isRecurring: Bool
    var recurrence: TransactionRecurrence?
    var recurringGroupId: UUID? // Links recurring instances together
    
    // Location
    var locationName: String?
    var locationAddress: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    
    init(id: UUID = UUID(), 
         amount: Decimal, 
         type: TransactionType, 
         category: Category, 
         accountId: UUID, 
         date: Date = Date(), 
         notes: String? = nil,
         toAccountId: UUID? = nil,
         isRecurring: Bool = false,
         recurrence: TransactionRecurrence? = nil,
         recurringGroupId: UUID? = nil,
         locationName: String? = nil,
         locationAddress: String? = nil,
         locationLatitude: Double? = nil,
         locationLongitude: Double? = nil) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.accountId = accountId
        self.date = date
        self.notes = notes
        self.toAccountId = toAccountId
        self.isRecurring = isRecurring
        self.recurrence = recurrence
        self.recurringGroupId = recurringGroupId
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
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

struct TransactionRecurrence: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int // e.g., every 2 weeks
    var endDate: Date?
    var dayOfWeek: Int? // 1-7 for Sunday-Saturday (for weekly)
    var dayOfMonth: Int? // 1-31 (for monthly)
    var monthOfYear: Int? // 1-12 (for yearly)
    
    func nextDate(after date: Date) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        
        switch frequency {
        case .daily:
            components.day = interval
            
        case .weekly:
            components.weekOfYear = interval
            if let dayOfWeek = dayOfWeek {
                let tempDate = calendar.date(byAdding: components, to: date) ?? date
                // Adjust to correct day of week
                let currentWeekday = calendar.component(.weekday, from: tempDate)
                let daysToAdd = (dayOfWeek - currentWeekday + 7) % 7
                let nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: tempDate) ?? tempDate
                return nextDate
            }
            
        case .monthly:
            components.month = interval
            if let dayOfMonth = dayOfMonth {
                var nextDate = calendar.date(byAdding: components, to: date) ?? date
                components = calendar.dateComponents([.year, .month], from: nextDate)
                components.day = dayOfMonth
                return calendar.date(from: components)
            }
            
        case .yearly:
            components.year = interval
        }
        
        return calendar.date(byAdding: components, to: date)
    }
}

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var localizedName: String {
        NSLocalizedString("recurrence_\(rawValue)", comment: "")
    }
}

// MARK: - Location

struct Location: Codable, Equatable, Identifiable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    
    var id: String {
        "\(latitude),\(longitude)"
    }
}
