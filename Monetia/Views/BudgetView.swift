import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.budgets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("no_budgets")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("create_first_budget") {
                            showingAddBudget = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(dataManager.getActiveBudgets()) { budget in
                        BudgetRow(budget: budget)
                    }
                    .onDelete(perform: deleteBudget)
                }
            }
            .navigationTitle("budget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func deleteBudget(at offsets: IndexSet) {
        let activeBudgets = dataManager.getActiveBudgets()
        for index in offsets {
            let budget = activeBudgets[index]
            dataManager.deleteBudget(budget)
        }
    }
}

struct BudgetRow: View {
    @EnvironmentObject var dataManager: DataManager
    let budget: Budget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                    
                    Text(budget.period.localizedName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(formatAmount(progress.spent)) / \(formatAmount(budget.amount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(Int(progress.percentage * 100))%")
                        .font(.caption)
                        .foregroundColor(progressColor)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: min(CGFloat(progress.percentage) * geometry.size.width, geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
            
            if progress.remaining < 0 {
                Text("budget_exceeded")
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("remaining: \(formatAmount(progress.remaining))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var progress: (spent: Decimal, remaining: Decimal, percentage: Double) {
        dataManager.getBudgetProgress(for: budget)
    }
    
    private var progressColor: Color {
        if progress.percentage >= 1.0 {
            return .red
        } else if progress.percentage >= 0.8 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "€0"
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var selectedCategory: Category?
    @State private var isOverallBudget = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("budget_details")) {
                    TextField("budget_name", text: $name)
                    
                    TextField("amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.localizedName).tag(period)
                        }
                    }
                }
                
                Section(header: Text("scope")) {
                    Toggle("overall_budget", isOn: $isOverallBudget)
                    
                    if !isOverallBudget {
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
            }
            .navigationTitle("add_budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveBudget()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard !name.isEmpty else { return false }
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount), amountValue > 0 else { return false }
        if !isOverallBudget && selectedCategory == nil {
            return false
        }
        return true
    }
    
    private func saveBudget() {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Decimal(string: normalizedAmount) else { return }
        
        let budget = Budget(
            name: name,
            amount: amountValue,
            period: selectedPeriod,
            categoryId: isOverallBudget ? nil : selectedCategory?.id
        )
        
        dataManager.addBudget(budget)
        dismiss()
    }
}
