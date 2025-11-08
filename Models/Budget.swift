import Foundation

struct Budget: Identifiable, Codable {
    var id: UUID
    var name: String
    var amount: Decimal
    var period: BudgetPeriod
    var categoryId: UUID?  // nil means overall budget
    var startDate: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         name: String, 
         amount: Decimal, 
         period: BudgetPeriod = .monthly, 
         categoryId: UUID? = nil, 
         startDate: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.period = period
        self.categoryId = categoryId
        self.startDate = startDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func isActive(on date: Date = Date()) -> Bool {
        return date >= startDate
    }
}

enum BudgetPeriod: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var localizedName: String {
        switch self {
        case .daily: return NSLocalizedString("budget_period_daily", comment: "")
        case .weekly: return NSLocalizedString("budget_period_weekly", comment: "")
        case .monthly: return NSLocalizedString("budget_period_monthly", comment: "")
        case .yearly: return NSLocalizedString("budget_period_yearly", comment: "")
        }
    }
    
    func startDate(for date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.startOfDay(for: date)
        case .weekly:
            return calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: date).date!
        case .monthly:
            return calendar.dateComponents([.year, .month], from: date).date!
        case .yearly:
            return calendar.dateComponents([.year], from: date).date!
        }
    }
    
    func endDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let start = startDate(for: date)
        
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: start)!
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: start)!
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: start)!
        }
    }
}
