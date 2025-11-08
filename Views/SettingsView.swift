import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingExportSheet = false
    @State private var exportedCSV = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("data")) {
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("export_data")
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("backup_to_icloud")
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                            Text("restore_from_icloud")
                        }
                    }
                }
                
                Section(header: Text("categories")) {
                    NavigationLink(destination: CategoriesManagementView()) {
                        HStack {
                            Image(systemName: "tag")
                            Text("manage_categories")
                        }
                    }
                }
                
                Section(header: Text("preferences")) {
                    HStack {
                        Text("default_currency")
                        Spacer()
                        Text("EUR")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("language")
                        Spacer()
                        Text("auto")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("about")) {
                    HStack {
                        Text("version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("transactions_count")
                        Spacer()
                        Text("\(dataManager.transactions.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("accounts_count")
                        Spacer()
                        Text("\(dataManager.accounts.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportSheet(csvData: exportedCSV)
            }
        }
    }
    
    private func exportData() {
        exportedCSV = dataManager.exportToCSV()
        showingExportSheet = true
    }
}

struct ExportSheet: View {
    @Environment(\.dismiss) var dismiss
    let csvData: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("export_ready")
                    .font(.headline)
                
                Text("export_instructions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                ShareLink(item: csvData) {
                    Label("share_csv", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoriesManagementView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddCategory = false
    
    var body: some View {
        List {
            ForEach(dataManager.categories) { category in
                CategoryRow(category: category)
            }
            .onDelete(perform: deleteCategory)
        }
        .navigationTitle("categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = dataManager.categories[index]
            if !category.isDefault {
                dataManager.deleteCategory(category)
            }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(category.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: category.icon)
                        .foregroundColor(.white)
                )
            
            Text(NSLocalizedString(category.name, comment: ""))
                .font(.headline)
            
            Spacer()
            
            if category.isDefault {
                Text("default")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
}

struct AddCategoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var selectedIcon = "star"
    @State private var selectedColor = "#007AFF"
    
    let iconOptions = [
        "star", "heart", "cart", "bag", "gift", "house", "car",
        "airplane", "tram", "bicycle", "gamecontroller", "book",
        "music.note", "film", "camera", "phone", "envelope",
        "folder", "doc", "scissors", "paintbrush", "wrench"
    ]
    
    let colorOptions = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
        "#F7B731", "#A29BFE", "#6C5CE7", "#00B894", "#95A5A6",
        "#E74C3C", "#3498DB", "#2ECC71", "#F39C12", "#9B59B6"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("category_name")) {
                    TextField("name", text: $name)
                }
                
                Section(header: Text("icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Button(action: { selectedColor = colorHex }) {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
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
                        Text(name.isEmpty ? "category_name" : name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("add_category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColor,
            isDefault: false
        )
        dataManager.addCategory(category)
        dismiss()
    }
}
