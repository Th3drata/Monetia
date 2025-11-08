import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(groupedTransactions[date] ?? []) { transaction in
                            TransactionRow(transaction: transaction)
                                .onTapGesture {
                                    Haptics.light()
                                    selectedTransaction = transaction
                                }
                        }
                        .onDelete { indexSet in
                            deleteTransactions(at: indexSet, in: date)
                        }
                    }
                }
            }
            .navigationTitle("transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Haptics.light()
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .sheet(item: $selectedTransaction) { transaction in
                EditTransactionView(transaction: transaction)
            }
        }
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        let calendar = Calendar.current
        var grouped: [Date: [Transaction]] = [:]
        
        for transaction in dataManager.transactions.sorted(by: { $0.date > $1.date }) {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: transaction.date)
            if let date = calendar.date(from: dateComponents) {
                grouped[date, default: []].append(transaction)
            }
        }
        
        return grouped
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func deleteTransactions(at offsets: IndexSet, in date: Date) {
        Haptics.medium()
        let transactionsForDate = groupedTransactions[date] ?? []
        for index in offsets {
            let transaction = transactionsForDate[index]
            dataManager.deleteTransaction(transaction)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(transaction.category.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.category.icon)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString(transaction.category.name, comment: ""))
                    .font(.headline)
                
                if let notes = transaction.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let accountName = dataManager.getAccount(byId: transaction.accountId)?.name {
                    Text(accountName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(formatAmount(transaction.amount, type: transaction.type))
                .font(.headline)
                .foregroundColor(amountColor(for: transaction.type))
        }
    }
    
    private func formatAmount(_ amount: Decimal, type: TransactionType) -> String {
        let sign = type == .income ? "+" : "-"
        return "\(sign) \(amount)"
    }
    
    private func amountColor(for type: TransactionType) -> Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}
