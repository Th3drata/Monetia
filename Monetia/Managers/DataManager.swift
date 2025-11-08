import Foundation
import Combine
import SwiftUI

enum AppTheme: String, Codable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppCurrency: String, Codable, CaseIterable {
    case eur = "EUR"
    case usd = "USD"
    case gbp = "GBP"
    case chf = "CHF"
    case jpy = "JPY"
    case cny = "CNY"
    
    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .gbp: return "£"
        case .chf: return "CHF"
        case .jpy: return "¥"
        case .cny: return "¥"
        }
    }
}

enum AppLanguage: String, Codable, CaseIterable {
    case auto = "auto"
    case french = "français"
    case english = "english"
    
    var localeIdentifier: String? {
        switch self {
        case .auto: return nil
        case .french: return "fr"
        case .english: return "en"
        }
    }
}

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    @Published var goals: [Goal] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var theme: AppTheme = .system
    @Published var currency: AppCurrency = .eur
    @Published var language: AppLanguage = .auto
    
    private let accountsKey = "accounts"
    private let transactionsKey = "transactions"
    private let categoriesKey = "categories"
    private let budgetsKey = "budgets"
    private let goalsKey = "goals"
    private let recurringTransactionsKey = "recurringTransactions"
    private let themeKey = "theme"
    private let currencyKey = "currency"
    private let languageKey = "language"
    
    private init() {
        loadData()
        if categories.isEmpty {
            categories = Category.defaultCategories
            saveCategories()
        }
        LocalizationManager.shared.currentLanguage = language
        
        // Update recurring transactions on app launch
        updateRecurringTransactions()
    }
    
    // MARK: - Load/Save
    
    private func loadData() {
        accounts = load([Account].self, forKey: accountsKey) ?? []
        transactions = load([Transaction].self, forKey: transactionsKey) ?? []
        categories = load([Category].self, forKey: categoriesKey) ?? []
        budgets = load([Budget].self, forKey: budgetsKey) ?? []
        goals = load([Goal].self, forKey: goalsKey) ?? []
        recurringTransactions = load([RecurringTransaction].self, forKey: recurringTransactionsKey) ?? []
        theme = load(AppTheme.self, forKey: themeKey) ?? .system
        currency = load(AppCurrency.self, forKey: currencyKey) ?? .eur
        language = load(AppLanguage.self, forKey: languageKey) ?? .auto
        
        // Process recurring transactions on startup
        processRecurringTransactions()
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // MARK: - Accounts
    
    func addAccount(_ account: Account) {
        accounts.append(account)
        saveAccounts()
    }
    
    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }
    
    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()
    }
    
    private func saveAccounts() {
        save(accounts, forKey: accountsKey)
    }
    
    func getAccount(byId id: UUID) -> Account? {
        return accounts.first { $0.id == id }
    }
    
    // MARK: - Transactions
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateAccountBalance(for: transaction)
        saveTransactions()
        saveAccounts()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let oldTransaction = transactions[index]
            revertAccountBalance(for: oldTransaction)
            transactions[index] = transaction
            updateAccountBalance(for: transaction)
            saveTransactions()
            saveAccounts()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        revertAccountBalance(for: transaction)
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
        saveAccounts()
    }
    
    private func saveTransactions() {
        save(transactions, forKey: transactionsKey)
    }
    
    private func updateAccountBalance(for transaction: Transaction) {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == transaction.accountId }) else { return }
        
        // Don't update balance for future transactions
        if transaction.date > Date() {
            return
        }
        
        switch transaction.type {
        case .income:
            accounts[accountIndex].balance += transaction.amount
        case .expense:
            accounts[accountIndex].balance -= transaction.amount
        case .transfer:
            accounts[accountIndex].balance -= transaction.amount
            if let toAccountId = transaction.toAccountId,
               let toAccountIndex = accounts.firstIndex(where: { $0.id == toAccountId }) {
                accounts[toAccountIndex].balance += transaction.amount
            }
        }
        accounts[accountIndex].updatedAt = Date()
    }
    
    private func revertAccountBalance(for transaction: Transaction) {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == transaction.accountId }) else { return }
        
        switch transaction.type {
        case .income:
            accounts[accountIndex].balance -= transaction.amount
        case .expense:
            accounts[accountIndex].balance += transaction.amount
        case .transfer:
            accounts[accountIndex].balance += transaction.amount
            if let toAccountId = transaction.toAccountId,
               let toAccountIndex = accounts.firstIndex(where: { $0.id == toAccountId }) {
                accounts[toAccountIndex].balance -= transaction.amount
            }
        }
        accounts[accountIndex].updatedAt = Date()
    }
    
    func getTransactions(for period: DateInterval) -> [Transaction] {
        // Only return past/present transactions for calculations
        return transactions.filter { period.contains($0.date) && $0.date <= Date() }
    }
    
    func getTransactions(for accountId: UUID) -> [Transaction] {
        return transactions.filter { $0.accountId == accountId || $0.toAccountId == accountId }
    }
    
    // MARK: - Categories
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    private func saveCategories() {
        save(categories, forKey: categoriesKey)
    }
    
    func getCategory(byId id: UUID) -> Category? {
        return categories.first { $0.id == id }
    }
    
    // MARK: - Budgets
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    private func saveBudgets() {
        save(budgets, forKey: budgetsKey)
    }
    
    // MARK: - Goals
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func addMoneyToGoal(goalId: UUID, amount: Decimal) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentAmount += amount
            goals[index].updatedAt = Date()
            saveGoals()
        }
    }
    
    private func saveGoals() {
        save(goals, forKey: goalsKey)
    }
    
    // MARK: - Theme
    
    func updateTheme(_ theme: AppTheme) {
        self.theme = theme
        save(theme, forKey: themeKey)
    }
    
    // MARK: - Currency
    
    func updateCurrency(_ currency: AppCurrency) {
        self.currency = currency
        save(currency, forKey: currencyKey)
    }
    
    // MARK: - Language
    
    func updateLanguage(_ language: AppLanguage) {
        self.language = language
        save(language, forKey: languageKey)
        LocalizationManager.shared.currentLanguage = language
        objectWillChange.send()
    }
    
    // MARK: - Helpers
    
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        return formatter
    }
    
    // MARK: - Recurring Transactions
    
    func addRecurringTransaction(_ recurring: RecurringTransaction) {
        recurringTransactions.append(recurring)
        saveRecurringTransactions()
    }
    
    func updateRecurringTransaction(_ recurring: RecurringTransaction) {
        if let index = recurringTransactions.firstIndex(where: { $0.id == recurring.id }) {
            recurringTransactions[index] = recurring
            saveRecurringTransactions()
        }
    }
    
    func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
        recurringTransactions.removeAll { $0.id == recurring.id }
        saveRecurringTransactions()
    }
    
    func toggleRecurringTransaction(_ id: UUID) {
        if let index = recurringTransactions.firstIndex(where: { $0.id == id }) {
            recurringTransactions[index].isActive.toggle()
            recurringTransactions[index].updatedAt = Date()
            saveRecurringTransactions()
        }
    }
    
    private func saveRecurringTransactions() {
        save(recurringTransactions, forKey: recurringTransactionsKey)
    }
    
    func processRecurringTransactions() {
        var updated = false
        
        for i in 0..<recurringTransactions.count {
            var recurring = recurringTransactions[i]
            
            while recurring.shouldGenerate() {
                // Generate transaction
                let transaction = recurring.toTransaction()
                addTransaction(transaction)
                
                // Update next occurrence
                recurring.updateNextOccurrence()
                updated = true
            }
            
            if updated {
                recurringTransactions[i] = recurring
            }
        }
        
        if updated {
            saveRecurringTransactions()
        }
    }
    
    // Schedule recurring transactions from a template
    func scheduleRecurringTransactions(from template: Transaction, recurrence: TransactionRecurrence) {
        guard let groupId = template.recurringGroupId else { return }
        
        // Only generate the next 2-3 months of occurrences
        let maxFutureMonths = 3
        let calendar = Calendar.current
        let maxDate = calendar.date(byAdding: .month, value: maxFutureMonths, to: Date()) ?? Date()
        
        var currentDate = template.date
        
        // Generate future occurrences up to maxDate
        while let nextDate = recurrence.nextDate(after: currentDate) {
            // Stop if beyond max date
            if nextDate > maxDate {
                break
            }
            
            // Stop if we've reached the end date
            if let endDate = recurrence.endDate, nextDate > endDate {
                break
            }
            
            // Create next occurrence
            let nextTransaction = Transaction(
                amount: template.amount,
                type: template.type,
                category: template.category,
                accountId: template.accountId,
                date: nextDate,
                notes: template.notes,
                toAccountId: template.toAccountId,
                isRecurring: true,
                recurrence: recurrence,
                recurringGroupId: groupId
            )
            
            addTransaction(nextTransaction)
            currentDate = nextDate
        }
    }
    
    // Check and generate new recurring transactions (call on app launch)
    func updateRecurringTransactions() {
        let calendar = Calendar.current
        let maxDate = calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        
        // Group transactions by recurringGroupId
        var recurringGroups: [UUID: [Transaction]] = [:]
        for transaction in transactions where transaction.isRecurring {
            if let groupId = transaction.recurringGroupId {
                recurringGroups[groupId, default: []].append(transaction)
            }
        }
        
        // For each recurring group, check if we need to generate more
        for (groupId, group) in recurringGroups {
            guard let template = group.first,
                  let recurrence = template.recurrence else { continue }
            
            // Find the latest transaction in this group
            guard let latestTransaction = group.max(by: { $0.date < $1.date }) else { continue }
            
            // Check if we need to generate more
            var currentDate = latestTransaction.date
            
            while let nextDate = recurrence.nextDate(after: currentDate) {
                if nextDate > maxDate { break }
                if let endDate = recurrence.endDate, nextDate > endDate { break }
                
                // Check if this transaction already exists
                let exists = transactions.contains { transaction in
                    transaction.recurringGroupId == groupId &&
                    calendar.isDate(transaction.date, inSameDayAs: nextDate)
                }
                
                if !exists {
                    let nextTransaction = Transaction(
                        amount: template.amount,
                        type: template.type,
                        category: template.category,
                        accountId: template.accountId,
                        date: nextDate,
                        notes: template.notes,
                        toAccountId: template.toAccountId,
                        isRecurring: true,
                        recurrence: recurrence,
                        recurringGroupId: groupId
                    )
                    addTransaction(nextTransaction)
                }
                
                currentDate = nextDate
            }
        }
    }
    
    func getActiveBudgets() -> [Budget] {
        return budgets.filter { $0.isActive() }
    }
    
    // MARK: - Analytics
    
    func getTotalBalance() -> Decimal {
        // Recalculate balance from past transactions only
        var balances: [UUID: Decimal] = [:]
        
        // Start with initial balances (would need to be stored separately in real app)
        for account in accounts {
            balances[account.id] = 0
        }
        
        // Add only past transactions
        for transaction in transactions where transaction.date <= Date() {
            switch transaction.type {
            case .income:
                balances[transaction.accountId, default: 0] += transaction.amount
            case .expense:
                balances[transaction.accountId, default: 0] -= transaction.amount
            case .transfer:
                balances[transaction.accountId, default: 0] -= transaction.amount
                if let toAccountId = transaction.toAccountId {
                    balances[toAccountId, default: 0] += transaction.amount
                }
            }
        }
        
        return balances.values.reduce(0, +)
    }
    
    func getIncomeForPeriod(_ period: DateInterval) -> Decimal {
        return getTransactions(for: period)
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesForPeriod(_ period: DateInterval) -> Decimal {
        return getTransactions(for: period)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory(for period: DateInterval) -> [UUID: Decimal] {
        var result: [UUID: Decimal] = [:]
        let expenses = getTransactions(for: period).filter { $0.type == .expense }
        
        for transaction in expenses {
            let categoryId = transaction.category.id
            result[categoryId, default: 0] += transaction.amount
        }
        
        return result
    }
    
    func getBudgetProgress(for budget: Budget, on date: Date = Date()) -> (spent: Decimal, remaining: Decimal, percentage: Double) {
        let startDate = budget.period.startDate(for: date)
        let endDate = budget.period.endDate(for: date)
        let period = DateInterval(start: startDate, end: endDate)
        
        let spent: Decimal
        if let categoryId = budget.categoryId {
            spent = getTransactions(for: period)
                .filter { $0.type == .expense && $0.category.id == categoryId }
                .reduce(0) { $0 + $1.amount }
        } else {
            spent = getExpensesForPeriod(period)
        }
        
        let remaining = budget.amount - spent
        let percentage = Double(truncating: (spent / budget.amount) as NSDecimalNumber)
        
        return (spent, remaining, percentage)
    }
    
    // MARK: - Export
    
    func exportToCSV() -> String {
        var csv = "Date,Type,Category,Amount,Account,Notes\n"
        
        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let date = dateFormatter.string(from: transaction.date)
            let type = transaction.type.rawValue
            let category = transaction.category.name
            let amount = "\(transaction.amount)"
            let account = getAccount(byId: transaction.accountId)?.name ?? ""
            let notes = transaction.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csv += "\(date),\(type),\(category),\(amount),\(account),\(notes)\n"
        }
        
        return csv
    }
    
    // MARK: - Backup/Restore
    
    struct FullBackup: Codable {
        let accounts: [Account]
        let transactions: [Transaction]
        let categories: [Category]
        let budgets: [Budget]
        let goals: [Goal]
        let recurringTransactions: [RecurringTransaction]
        let theme: AppTheme
        let currency: AppCurrency
        let language: AppLanguage
        let backupDate: Date
        let appVersion: String
    }
    
    func exportToJSON() -> String? {
        let backup = FullBackup(
            accounts: accounts,
            transactions: transactions,
            categories: categories,
            budgets: budgets,
            goals: goals,
            recurringTransactions: recurringTransactions,
            theme: theme,
            currency: currency,
            language: language,
            backupDate: Date(),
            appVersion: "1.1"
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(backup) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func importFromJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let backup = try? decoder.decode(FullBackup.self, from: data) else { return false }
        
        // Restore all data
        self.accounts = backup.accounts
        self.transactions = backup.transactions
        self.categories = backup.categories
        self.budgets = backup.budgets
        self.goals = backup.goals
        self.recurringTransactions = backup.recurringTransactions
        self.theme = backup.theme
        self.currency = backup.currency
        self.language = backup.language
        
        // Save to UserDefaults
        saveAccounts()
        saveTransactions()
        saveCategories()
        saveBudgets()
        saveGoals()
        saveRecurringTransactions()
        save(theme, forKey: themeKey)
        save(currency, forKey: currencyKey)
        save(language, forKey: languageKey)
        
        // Update localization
        LocalizationManager.shared.currentLanguage = language
        objectWillChange.send()
        
        return true
    }
}
