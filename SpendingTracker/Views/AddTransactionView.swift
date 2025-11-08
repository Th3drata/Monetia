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
            }
            .navigationTitle("add_transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
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
        guard let amountValue = Decimal(string: amount), amountValue > 0 else { return false }
        guard selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Decimal(string: amount),
              let account = selectedAccount else { return }
        
        let category = selectedCategory ?? Category.other
        
        let transaction = Transaction(
            amount: amountValue,
            type: selectedType,
            category: category,
            accountId: account.id,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            toAccountId: selectedToAccount?.id
        )
        
        dataManager.addTransaction(transaction)
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
            }
            .navigationTitle("edit_transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
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
            amount = "\(transaction.amount)"
            selectedType = transaction.type
            selectedCategory = transaction.category
            selectedAccount = dataManager.getAccount(byId: transaction.accountId)
            if let toAccountId = transaction.toAccountId {
                selectedToAccount = dataManager.getAccount(byId: toAccountId)
            }
            date = transaction.date
            notes = transaction.notes ?? ""
        }
    }
    
    private var isValid: Bool {
        guard let amountValue = Decimal(string: amount), amountValue > 0 else { return false }
        guard selectedAccount != nil else { return false }
        
        if selectedType == .transfer {
            return selectedToAccount != nil && selectedToAccount?.id != selectedAccount?.id
        } else {
            return selectedCategory != nil
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Decimal(string: amount),
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
        
        dataManager.updateTransaction(updatedTransaction)
        dismiss()
    }
}
