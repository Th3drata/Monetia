import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var budgets: [Budget] = []
    
    private let accountsKey = "accounts"
    private let transactionsKey = "transactions"
    private let categoriesKey = "categories"
    private let budgetsKey = "budgets"
    
    private init() {
        loadData()
        if categories.isEmpty {
            categories = Category.defaultCategories
            saveCategories()
        }
    }
    
    // MARK: - Load/Save
    
    private func loadData() {
        accounts = load([Account].self, forKey: accountsKey) ?? []
        transactions = load([Transaction].self, forKey: transactionsKey) ?? []
        categories = load([Category].self, forKey: categoriesKey) ?? []
        budgets = load([Budget].self, forKey: budgetsKey) ?? []
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
        return transactions.filter { period.contains($0.date) }
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
    
    func getActiveBudgets() -> [Budget] {
        return budgets.filter { $0.isActive() }
    }
    
    // MARK: - Analytics
    
    func getTotalBalance() -> Decimal {
        return accounts.reduce(0) { $0 + $1.balance }
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
}
