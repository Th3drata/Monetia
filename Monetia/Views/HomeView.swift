import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: TimePeriod = .thisMonth
    @State private var showingAddAccount = false
    @State private var isEditingAccounts = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Balance
                    VStack(spacing: 8) {
                        Text("total_balance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(formatCurrency(dataManager.getTotalBalance()))
                            .font(.system(size: 36, weight: .bold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Period Selector
                    Picker("period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.localizedName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Income vs Expenses
                    HStack(spacing: 16) {
                        FinancialCard(
                            title: "income",
                            amount: dataManager.getIncomeForPeriod(selectedPeriod.dateInterval),
                            color: .green
                        )
                        
                        FinancialCard(
                            title: "expenses",
                            amount: dataManager.getExpensesForPeriod(selectedPeriod.dateInterval),
                            color: .red
                        )
                    }
                    
                    // Expenses by Category Chart
                    if !expensesByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("expenses_by_category")
                                .font(.headline)
                            
                            CategoryChartView(data: expensesByCategory)
                                .frame(height: 200)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // Accounts List
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("accounts")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                Haptics.light()
                                withAnimation {
                                    isEditingAccounts.toggle()
                                }
                            }) {
                                Image(systemName: isEditingAccounts ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                                    .foregroundColor(isEditingAccounts ? .green : .blue)
                            }
                            
                            Button(action: { showingAddAccount = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        
                        if dataManager.accounts.isEmpty {
                            Text("no_accounts")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            List {
                                ForEach(dataManager.accounts) { account in
                                    AccountRow(account: account)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowBackground(Color.clear)
                                        .contextMenu {
                                            Button(role: .destructive, action: {
                                                Haptics.medium()
                                                deleteAccount(account)
                                            }) {
                                                Label("delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onMove(perform: moveAccount)
                            }
                            .listStyle(.plain)
                            .frame(height: CGFloat(dataManager.accounts.count * 70))
                            .environment(\.editMode, isEditingAccounts ? .constant(.active) : .constant(.inactive))
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("home")
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var expensesByCategory: [(Category, Decimal)] {
        let expensesDict = dataManager.getExpensesByCategory(for: selectedPeriod.dateInterval)
        return expensesDict.compactMap { categoryId, amount in
            if let category = dataManager.getCategory(byId: categoryId) {
                return (category, amount)
            }
            return nil
        }.sorted { $0.1 > $1.1 }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "€0.00"
    }
    
    private func deleteAccount(_ account: Account) {
        dataManager.deleteAccount(account)
    }
    
    private func moveAccount(from source: IndexSet, to destination: Int) {
        Haptics.light()
        dataManager.moveAccount(from: source, to: destination)
    }
}

struct FinancialCard: View {
    let title: String
    let amount: Decimal
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(amount))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "€0.00"
    }
}

struct AccountRow: View {
    let account: Account
    
    var body: some View {
        HStack {
            Image(systemName: account.type.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                
                Text(NSLocalizedString(account.type.rawValue, comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatCurrency(account.balance))
                .font(.headline)
                .foregroundColor(account.balance >= 0 ? .primary : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = account.currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "€0.00"
    }
}

struct CategoryChartView: View {
    let data: [(Category, Decimal)]
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Chart {
                ForEach(data, id: \.0.id) { category, amount in
                    SectorMark(
                        angle: .value("Amount", Double(truncating: amount as NSDecimalNumber)),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(category.color)
                    .annotation(position: .overlay) {
                        if data.count <= 5 {
                            Text(NSLocalizedString(category.name, comment: ""))
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        } else {
            // Fallback for iOS 15
            VStack(spacing: 8) {
                ForEach(data, id: \.0.id) { category, amount in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        
                        Text(NSLocalizedString(category.name, comment: ""))
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(amount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case thisWeek
    case thisMonth
    case lastMonth
    case thisYear
    
    var localizedName: String {
        NSLocalizedString("period_\(rawValue)", comment: "")
    }
    
    var dateInterval: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .thisWeek:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            let startOfWeek = calendar.date(from: components) ?? calendar.startOfDay(for: now)
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? now
            return DateInterval(start: startOfWeek, end: endOfWeek)
            
        case .thisMonth:
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components) ?? calendar.startOfDay(for: now)
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now
            return DateInterval(start: startOfMonth, end: endOfMonth)
            
        case .lastMonth:
            let thisMonthComponents = calendar.dateComponents([.year, .month], from: now)
            let startOfThisMonth = calendar.date(from: thisMonthComponents) ?? calendar.startOfDay(for: now)
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth) ?? startOfThisMonth
            return DateInterval(start: startOfLastMonth, end: startOfThisMonth)
            
        case .thisYear:
            let components = calendar.dateComponents([.year], from: now)
            let startOfYear = calendar.date(from: components) ?? calendar.startOfDay(for: now)
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? now
            return DateInterval(start: startOfYear, end: endOfYear)
        }
    }
}

struct AddAccountView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedType: AccountType = .checking
    @State private var initialBalance = ""
    @State private var currency = "EUR"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("account_details")) {
                    TextField("account_name", text: $name)
                    
                    Picker("account_type", selection: $selectedType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(NSLocalizedString(type.rawValue, comment: ""))
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("initial_balance", text: $initialBalance)
                        .keyboardType(.decimalPad)
                    
                    TextField("currency", text: $currency)
                }
            }
            .navigationTitle("add_account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("cancel") {
                    dismiss()
                },
                trailing: Button("save") {
                    saveAccount()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func saveAccount() {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedBalance = initialBalance.replacingOccurrences(of: ",", with: ".")
        let balance = Decimal(string: normalizedBalance) ?? 0
        let account = Account(
            name: name,
            type: selectedType,
            balance: balance,
            currency: currency
        )
        dataManager.addAccount(account)
        dismiss()
    }
}
