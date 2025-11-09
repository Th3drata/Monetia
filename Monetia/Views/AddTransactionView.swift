import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var amount = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var date = Date()
    @State private var notes = ""
    
    // Recurrence
    @State private var isRecurring = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .monthly
    @State private var recurrenceInterval = 1
    @State private var recurrenceEndDate: Date?
    @State private var hasEndDate = false
    @State private var selectedDayOfWeek = 1 // Sunday
    @State private var selectedDayOfMonth = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("amount")) {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("type")) {
                    Picker("type", selection: $selectedType) {
                        Text("expense").tag(TransactionType.expense)
                        Text("income").tag(TransactionType.income)
                        Text("transfer").tag(TransactionType.transfer)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) { _ in
                        Haptics.selection()
                    }
                }
                
                if selectedType != .transfer {
                    Section(header: Text("category")) {
                        Picker("category", selection: $selectedCategory) {
                            Text("select_category").tag(nil as Category?)
                            ForEach(dataManager.categories) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(NSLocalizedString(category.name, comment: ""))
                                }
                                .tag(category as Category?)
                            }
                        }
                    }
                }
                
                Section(header: Text("account")) {
                    Picker("from_account", selection: $selectedAccount) {
                        Text("select_account").tag(nil as Account?)
                        ForEach(dataManager.accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    
                    if selectedType == .transfer {
                        Picker("to_account", selection: $selectedToAccount) {
                            Text("select_account").tag(nil as Account?)
                            ForEach(dataManager.accounts) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                    }
                }
                
                Section(header: Text("date")) {
                    DatePicker("date", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                // Recurrence Section
                Section(header: Text("recurrence")) {
                    Toggle("is_recurring", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("frequency", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                                Text(freq.localizedName).tag(freq)
                            }
                        }
                        
                        // Day of week selection (for weekly)
                        if recurrenceFrequency == .weekly {
                            Picker("day_of_week", selection: $selectedDayOfWeek) {
                                Text(NSLocalizedString("sunday", comment: "")).tag(1)
                                Text(NSLocalizedString("monday", comment: "")).tag(2)
                                Text(NSLocalizedString("tuesday", comment: "")).tag(3)
                                Text(NSLocalizedString("wednesday", comment: "")).tag(4)
                                Text(NSLocalizedString("thursday", comment: "")).tag(5)
                                Text(NSLocalizedString("friday", comment: "")).tag(6)
                                Text(NSLocalizedString("saturday", comment: "")).tag(7)
                            }
                        }
                        
                        // Day of month selection (for monthly)
                        if recurrenceFrequency == .monthly {
                            Stepper("day_of_month: \(selectedDayOfMonth)", value: $selectedDayOfMonth, in: 1...31)
                        }
                        
                        Toggle("has_end_date", isOn: $hasEndDate)
                        
                        if hasEndDate {
                            DatePicker("end_date", selection: Binding(
                                get: { recurrenceEndDate ?? Date() },
                                set: { recurrenceEndDate = $0 }
                            ), displayedComponents: [.date])
                        }
                    }
                }
            }
            .navigationTitle("add_transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        Haptics.light()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if selectedAccount == nil, let firstAccount = dataManager.accounts.first {
                selectedAccount = firstAccount
            }
            if selectedCategory == nil, let firstCategory = dataManager.categories.first {
                selectedCategory = firstCategory
            }
        }
    }
    
    private var isValid: Bool {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount), amountValue > 0 else { return false }
        guard selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func saveTransaction() {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount),
              let account = selectedAccount else { return }
        
        let category = selectedCategory ?? Category.other
        
        // Create recurrence if enabled
        var recurrence: TransactionRecurrence? = nil
        if isRecurring {
            recurrence = TransactionRecurrence(
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                endDate: hasEndDate ? recurrenceEndDate : nil,
                dayOfWeek: recurrenceFrequency == .weekly ? selectedDayOfWeek : nil,
                dayOfMonth: recurrenceFrequency == .monthly ? selectedDayOfMonth : nil,
                monthOfYear: nil
            )
        }
        
        let groupId = isRecurring ? UUID() : nil
        
        let transaction = Transaction(
            amount: amountValue,
            type: selectedType,
            category: category,
            accountId: account.id,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            toAccountId: selectedToAccount?.id,
            isRecurring: isRecurring,
            recurrence: recurrence,
            recurringGroupId: groupId
        )
        
        Haptics.success()
        dataManager.addTransaction(transaction)
        
        // If recurring, schedule future transactions
        if isRecurring, let recurrence = recurrence {
            dataManager.scheduleRecurringTransactions(from: transaction, recurrence: recurrence)
        }
        
        dismiss()
    }
}

struct EditTransactionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    let transaction: Transaction
    
    @State private var amount = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var selectedToAccount: Account?
    @State private var date = Date()
    @State private var notes = ""
    @State private var isRecurringEnabled = false
    @State private var showingDisableAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("amount")) {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("type")) {
                    Picker("type", selection: $selectedType) {
                        Text("expense").tag(TransactionType.expense)
                        Text("income").tag(TransactionType.income)
                        Text("transfer").tag(TransactionType.transfer)
                    }
                    .pickerStyle(.segmented)
                }
                
                if selectedType != .transfer {
                    Section(header: Text("category")) {
                        Picker("category", selection: $selectedCategory) {
                            ForEach(dataManager.categories) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(NSLocalizedString(category.name, comment: ""))
                                }
                                .tag(category as Category?)
                            }
                        }
                    }
                }
                
                Section(header: Text("account")) {
                    Picker("from_account", selection: $selectedAccount) {
                        ForEach(dataManager.accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    
                    if selectedType == .transfer {
                        Picker("to_account", selection: $selectedToAccount) {
                            Text("select_account").tag(nil as Account?)
                            ForEach(dataManager.accounts) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                    }
                }
                
                Section(header: Text("date")) {
                    DatePicker("date", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
                
                // Recurrence control (only if transaction is recurring)
                if transaction.isRecurring {
                    Section(header: Text("recurrence")) {
                        Toggle("recurrence_active", isOn: $isRecurringEnabled)
                            .onChange(of: isRecurringEnabled) { newValue in
                                if !newValue {
                                    showingDisableAlert = true
                                }
                            }
                        
                        if let recurrence = transaction.recurrence {
                            HStack {
                                Text("frequency")
                                Spacer()
                                Text(recurrence.frequency.localizedName)
                                    .foregroundColor(.secondary)
                            }
                            
                            if recurrence.frequency == .weekly, let dayOfWeek = recurrence.dayOfWeek {
                                HStack {
                                    Text("day_of_week")
                                    Spacer()
                                    Text(dayOfWeekName(dayOfWeek))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if recurrence.frequency == .monthly, let dayOfMonth = recurrence.dayOfMonth {
                                HStack {
                                    Text("day_of_month")
                                    Spacer()
                                    Text("\(dayOfMonth)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("edit_transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        Haptics.light()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .alert("disable_recurrence_title", isPresented: $showingDisableAlert) {
            Button("cancel", role: .cancel) {
                isRecurringEnabled = true
            }
            Button("disable", role: .destructive) {
                disableRecurrence()
            }
        } message: {
            Text("disable_recurrence_message")
        }
        .onAppear {
            amount = "\(transaction.amount)"
            selectedType = transaction.type
            selectedCategory = transaction.category
            selectedAccount = dataManager.getAccount(byId: transaction.accountId)
            if let toAccountId = transaction.toAccountId {
                selectedToAccount = dataManager.getAccount(byId: toAccountId)
            }
            date = transaction.date
            notes = transaction.notes ?? ""
            isRecurringEnabled = transaction.isRecurring
        }
    }
    
    private var isValid: Bool {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount), amountValue > 0 else { return false }
        guard selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func saveTransaction() {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount),
              let account = selectedAccount,
              let category = selectedCategory else { return }
        
        var updatedTransaction = transaction
        updatedTransaction.amount = amountValue
        updatedTransaction.type = selectedType
        updatedTransaction.category = category
        updatedTransaction.accountId = account.id
        updatedTransaction.date = date
        updatedTransaction.notes = notes.isEmpty ? nil : notes
        updatedTransaction.toAccountId = selectedToAccount?.id
        updatedTransaction.updatedAt = Date()
        
        Haptics.success()
        dataManager.updateTransaction(updatedTransaction)
        dismiss()
    }
    
    private func disableRecurrence() {
        guard let groupId = transaction.recurringGroupId else { return }
        
        // Delete all future transactions in this recurring group
        dataManager.deleteFutureRecurringTransactions(groupId: groupId, after: transaction.date)
        
        // Update current transaction to non-recurring
        var updatedTransaction = transaction
        updatedTransaction.isRecurring = false
        updatedTransaction.recurrence = nil
        updatedTransaction.updatedAt = Date()
        dataManager.updateTransaction(updatedTransaction)
        
        Haptics.medium()
        dismiss()
    }
    
    private func dayOfWeekName(_ day: Int) -> String {
        let days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let index = day - 1
        return NSLocalizedString(days[index], comment: "")
    }
}
