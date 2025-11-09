import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    @State private var showingUpcoming = false
    
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
            .refreshable {
                await refresh()
            }
            .navigationTitle("transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Haptics.light()
                        showingUpcoming = true
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("upcoming")
                        }
                    }
                }
                
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
            .sheet(isPresented: $showingUpcoming) {
                UpcomingTransactionsView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        let calendar = Calendar.current
        var grouped: [Date: [Transaction]] = [:]
        
        // Only show past/present transactions in main list
        let now = Date()
        for transaction in dataManager.transactions.filter({ $0.date <= now }).sorted(by: { $0.date > $1.date }) {
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
    
    private func refresh() async {
        // Update recurring transactions
        dataManager.updateRecurringTransactions()
        
        // Add a small delay to show the loading indicator
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Haptic feedback on completion
        Haptics.success()
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
                HStack {
                    Text(NSLocalizedString(transaction.category.name, comment: ""))
                        .font(.headline)
                    
                    // Badge for future/scheduled transactions
                    if transaction.date > Date() {
                        Text("scheduled")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
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
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatAmount(transaction.amount, type: transaction.type, accountId: transaction.accountId))
                    .font(.headline)
                    .foregroundColor(transaction.date > Date() ? .secondary : amountColor(for: transaction.type))
                
                if transaction.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .opacity(transaction.date > Date() ? 0.6 : 1.0)
    }
    
    private func formatAmount(_ amount: Decimal, type: TransactionType, accountId: UUID) -> String {
        let sign = type == .income ? "+" : "-"
        let currency = dataManager.getAccount(byId: accountId)?.currency ?? "EUR"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        
        if let formattedAmount = formatter.string(from: amount as NSDecimalNumber) {
            // Remove the sign if present in formatted string and add our own
            let cleanAmount = formattedAmount.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
            return "\(sign) \(cleanAmount)"
        }
        
        return "\(sign) \(amount) \(currency)"
    }
    
    private func amountColor(for type: TransactionType) -> Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}

struct UpcomingTransactionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedUpcomingTransactions.keys.sorted(), id: \.self) { date in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(groupedUpcomingTransactions[date] ?? []) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
            .navigationTitle("upcoming_transactions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done") {
                dismiss()
            })
        }
    }
    
    private var groupedUpcomingTransactions: [Date: [Transaction]] {
        let calendar = Calendar.current
        var grouped: [Date: [Transaction]] = [:]
        
        let now = Date()
        // Show next 3 months instead of just current month
        let endDate = calendar.date(byAdding: .month, value: 3, to: now) ?? now
        
        // Show future transactions within next 3 months
        for transaction in dataManager.transactions.filter({ $0.date > now && $0.date <= endDate }).sorted(by: { $0.date < $1.date }) {
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
}
