import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            Group {
                if dataManager.goals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "flag.circle")
                            .font(.system(size: 70))
                            .foregroundColor(.secondary)
                        
                        Text("no_goals")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("create_first_goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(dataManager.goals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)) {
                                GoalRow(goal: goal)
                            }
                        }
                        .onDelete(perform: deleteGoals)
                    }
                }
            }
            .navigationTitle("goals")
            .navigationBarItems(trailing: Button(action: {
                Haptics.light()
                showingAddGoal = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func deleteGoals(at offsets: IndexSet) {
        Haptics.medium()
        for index in offsets {
            let goal = dataManager.goals[index]
            dataManager.deleteGoal(goal)
        }
    }
}

struct GoalRow: View {
    @EnvironmentObject var dataManager: DataManager
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(goal.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: goal.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.headline)
                
                HStack {
                    Text("\(goal.currentAmount as NSDecimalNumber, formatter: dataManager.currencyFormatter) / \(goal.targetAmount as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                ProgressView(value: goal.progress)
                    .tint(goal.color)
            }
        }
        .padding(.vertical, 4)
    }
}

struct GoalDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    
    @State private var amountToAdd = ""
    @State private var showingAddMoney = false
    @State private var showingEditGoal = false
    
    var currentGoal: Goal? {
        dataManager.goals.first { $0.id == goal.id }
    }
    
    var body: some View {
        List {
            if let currentGoal = currentGoal {
                Section {
                    VStack(spacing: 20) {
                        Circle()
                            .fill(currentGoal.color)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: currentGoal.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                        
                        Text(currentGoal.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("current")
                                Spacer()
                                Text("\(currentGoal.currentAmount as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("target")
                                Spacer()
                                Text("\(currentGoal.targetAmount as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("remaining")
                                Spacer()
                                Text("\(currentGoal.remaining as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                                    .fontWeight(.bold)
                                    .foregroundColor(currentGoal.isCompleted ? .green : .orange)
                            }
                        }
                        .font(.subheadline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("progress")
                                Spacer()
                                Text("\(Int(currentGoal.progress * 100))%")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            
                            ProgressView(value: currentGoal.progress)
                                .tint(currentGoal.color)
                                .scaleEffect(y: 2)
                        }
                        
                        if currentGoal.isCompleted {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("goal_completed")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section {
                    Button(action: {
                        Haptics.light()
                        showingAddMoney = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add_money")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        Haptics.light()
                        showingEditGoal = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("edit_goal")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("goal_details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddMoney) {
            AddMoneySheet(goal: currentGoal ?? goal, amountToAdd: $amountToAdd) {
                if let amount = Decimal(string: amountToAdd) {
                    let wasCompleted = currentGoal?.isCompleted ?? false
                    dataManager.addMoneyToGoal(goalId: goal.id, amount: amount)
                    let isNowCompleted = dataManager.goals.first { $0.id == goal.id }?.isCompleted ?? false
                    
                    if !wasCompleted && isNowCompleted {
                        Haptics.success()
                    } else {
                        Haptics.medium()
                    }
                    
                    amountToAdd = ""
                    showingAddMoney = false
                }
            }
        }
        .sheet(isPresented: $showingEditGoal) {
            if let currentGoal = currentGoal {
                AddGoalView(goal: currentGoal)
            }
        }
    }
}

struct AddMoneySheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    @Binding var amountToAdd: String
    let onAdd: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("amount")) {
                    TextField("0.00", text: $amountToAdd)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    HStack {
                        Text("current")
                        Spacer()
                        Text("\(goal.currentAmount as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                    }
                    
                    if let amount = Decimal(string: amountToAdd), amount > 0 {
                        HStack {
                            Text("new_total")
                            Spacer()
                            Text("\((goal.currentAmount + amount) as NSDecimalNumber, formatter: dataManager.currencyFormatter)")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("add_money")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("cancel") {
                    Haptics.light()
                    dismiss()
                },
                trailing: Button("add") {
                    onAdd()
                }
                .disabled(Decimal(string: amountToAdd) == nil || Decimal(string: amountToAdd) ?? 0 <= 0)
            )
        }
    }
}

