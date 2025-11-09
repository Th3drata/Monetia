import SwiftUI

struct AddGoalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    var goal: Goal?
    
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var selectedIcon = "star"
    @State private var selectedColor = "#007AFF"
    
    let iconOptions = [
        "star", "heart", "cart", "bag", "gift", "house", "car",
        "airplane", "tram", "bicycle", "bus", "fork.knife", "cup.and.saucer",
        "birthday.cake", "tshirt", "shoe", "gamecontroller", "book", "music.note",
        "film", "camera", "phone", "tv", "laptopcomputer", "creditcard",
        "banknote", "dollarsign", "eurosign", "briefcase", "graduationcap",
        "stethoscope", "pills", "lightbulb", "bolt", "drop", "flame",
        "wrench", "paintbrush", "leaf", "sparkles", "envelope", "folder"
    ]
    
    let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
        "#F7B731", "#A29BFE", "#6C5CE7", "#00B894", "#95A5A6",
        "#E74C3C", "#3498DB", "#2ECC71", "#F39C12", "#9B59B6"
    ]
    
    var isEditing: Bool {
        goal != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("goal_name")) {
                    TextField("name", text: $name)
                }
                
                Section(header: Text("target_amount")) {
                    TextField("0.00", text: $targetAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            VStack {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                            }
                            .onTapGesture {
                                Haptics.light()
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    Haptics.light()
                                    selectedColor = colorHex
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    HStack {
                        Text("preview")
                            .foregroundColor(.secondary)
                        Spacer()
                        Circle()
                            .fill(Color(hex: selectedColor) ?? .blue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: selectedIcon)
                                    .foregroundColor(.white)
                            )
                        Text(name.isEmpty ? "goal_name" : name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle(isEditing ? "edit_goal" : "add_goal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("cancel") {
                    Haptics.light()
                    dismiss()
                },
                trailing: Button("save") {
                    saveGoal()
                }
                .disabled({
                    let normalized = targetAmount.replacingOccurrences(of: ",", with: ".")
                    return name.isEmpty || Decimal(string: normalized) == nil || Decimal(string: normalized) ?? 0 <= 0
                }())
            )
            .onAppear {
                if let goal = goal {
                    name = goal.name
                    targetAmount = "\(goal.targetAmount)"
                    selectedIcon = goal.icon
                    selectedColor = goal.colorHex
                }
            }
        }
    }
    
    private func saveGoal() {
        // Replace comma with dot for decimal parsing (supports both European and US formats)
        let normalizedAmount = targetAmount.replacingOccurrences(of: ",", with: ".")
        guard let amount = Decimal(string: normalizedAmount) else { return }
        
        Haptics.success()
        
        if let existingGoal = goal {
            var updatedGoal = existingGoal
            updatedGoal.name = name
            updatedGoal.targetAmount = amount
            updatedGoal.icon = selectedIcon
            updatedGoal.colorHex = selectedColor
            updatedGoal.updatedAt = Date()
            dataManager.updateGoal(updatedGoal)
        } else {
            let newGoal = Goal(
                name: name,
                icon: selectedIcon,
                colorHex: selectedColor,
                targetAmount: amount
            )
            dataManager.addGoal(newGoal)
        }
        
        dismiss()
    }
}
