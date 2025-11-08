import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingExportSheet = false
    @State private var exportedCSV = ""
    @State private var showingBackupSheet = false
    @State private var showingRestoreSheet = false
    @State private var showingRestoreAlert = false
    @State private var restoreSuccess = false
    @State private var lastBackupDate: Date?
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("data")) {
                    Button(action: {
                        Haptics.light()
                        exportData()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("export_data")
                        }
                    }
                    
                    Button(action: {
                        Haptics.light()
                        backupToJSON()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("backup_json")
                        }
                    }
                    
                    Button(action: {
                        Haptics.light()
                        showingRestoreSheet = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                            Text("restore_json")
                        }
                    }
                    
                    if let lastBackup = lastBackupDate {
                        HStack {
                            Text("last_backup")
                            Spacer()
                            Text(lastBackup, style: .relative)
                                .foregroundColor(.secondary)
                                .font(.caption)
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
                        Text("appearance")
                        Spacer()
                        Picker("", selection: $dataManager.theme) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(NSLocalizedString(theme.rawValue, comment: "")).tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: dataManager.theme) { newTheme in
                            Haptics.selection()
                            dataManager.updateTheme(newTheme)
                        }
                    }
                    
                    HStack {
                        Text("default_currency")
                        Spacer()
                        Picker("", selection: $dataManager.currency) {
                            ForEach(AppCurrency.allCases, id: \.self) { currency in
                                Text("\(currency.rawValue) (\(currency.symbol))").tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: dataManager.currency) { newCurrency in
                            Haptics.selection()
                            dataManager.updateCurrency(newCurrency)
                        }
                    }
                    
                    HStack {
                        Text("language")
                        Spacer()
                        Picker("", selection: $dataManager.language) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: dataManager.language) { newLanguage in
                            Haptics.selection()
                            dataManager.updateLanguage(newLanguage)
                        }
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
            .sheet(isPresented: $showingBackupSheet) {
                if #available(iOS 16.0, *) {
                    BackupSheet(onBackupComplete: { lastBackupDate = Date() })
                } else {
                    BackupSheetLegacy(onBackupComplete: { lastBackupDate = Date() })
                }
            }
            .sheet(isPresented: $showingRestoreSheet) {
                if #available(iOS 16.0, *) {
                    RestoreSheet(onRestoreComplete: { success in
                        restoreSuccess = success
                        showingRestoreAlert = true
                    })
                } else {
                    RestoreSheetLegacy(onRestoreComplete: { success in
                        restoreSuccess = success
                        showingRestoreAlert = true
                    })
                }
            }
            .alert(isPresented: $showingRestoreAlert) {
                Alert(
                    title: Text(restoreSuccess ? "restore_success" : "restore_error"),
                    message: Text(restoreSuccess ? "restore_success_message" : "restore_error_message"),
                    dismissButton: .default(Text("ok"))
                )
            }
            .onAppear {
                loadLastBackupDate()
            }
        }
    }
    
    private func exportData() {
        exportedCSV = dataManager.exportToCSV()
        showingExportSheet = true
    }
    
    private func backupToJSON() {
        showingBackupSheet = true
    }
    
    private func loadLastBackupDate() {
        if let timestamp = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            lastBackupDate = timestamp
        }
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
                
                if #available(iOS 16.0, *) {
                    ShareLink(item: csvData) {
                        Label("share_csv", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: {
                        let activityVC = UIActivityViewController(activityItems: [csvData], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        Label("share_csv", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("export")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done") {
                dismiss()
            })
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
        .navigationBarItems(trailing: Button(action: {
            Haptics.light()
            showingAddCategory = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        Haptics.medium()
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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("category_name")) {
                    TextField("name", text: $name)
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
                        Text(name.isEmpty ? "category_name" : name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("add_category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("cancel") {
                    Haptics.light()
                    dismiss()
                },
                trailing: Button("save") {
                    saveCategory()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func saveCategory() {
        Haptics.success()
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

// MARK: - Backup/Restore Sheets

@available(iOS 16.0, *)
struct BackupSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    let onBackupComplete: () -> Void
    
    private func createBackupFile() -> URL? {
        guard let jsonString = dataManager.exportToJSON() else { return nil }
        
        let fileName = "Monetia_Backup_\(dateFormatter.string(from: Date())).json"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("backup_ready")
                    .font(.headline)
                
                Text("backup_instructions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let fileURL = createBackupFile() {
                    ShareLink(
                        item: fileURL,
                        preview: SharePreview(
                            "Monetia Backup",
                            image: Image(systemName: "doc.text")
                        )
                    ) {
                        Label("save_backup", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .simultaneousGesture(TapGesture().onEnded {
                        Haptics.success()
                        UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
                        onBackupComplete()
                    })
                } else {
                    Text("backup_error")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("backup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done") {
                dismiss()
            })
        }
    }
}

struct BackupSheetLegacy: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    let onBackupComplete: () -> Void
    
    private func createBackupFile() -> URL? {
        guard let jsonString = dataManager.exportToJSON() else { return nil }
        
        let fileName = "Monetia_Backup_\(dateFormatter.string(from: Date())).json"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("backup_ready")
                    .font(.headline)
                
                Text("backup_instructions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let fileURL = createBackupFile() {
                    Button(action: {
                        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            Haptics.success()
                            rootVC.present(activityVC, animated: true)
                            UserDefaults.standard.set(Date(), forKey: "lastBackupDate")
                            onBackupComplete()
                        }
                    }) {
                        Label("save_backup", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    Text("backup_error")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("backup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("done") {
                dismiss()
            })
        }
    }
}

@available(iOS 16.0, *)
struct RestoreSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedFile: URL?
    @State private var showingFilePicker = false
    let onRestoreComplete: (Bool) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("restore_title")
                    .font(.headline)
                
                Text("restore_warning")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("restore_instructions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: { showingFilePicker = true }) {
                    Label("select_backup_file", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("restore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("cancel") {
                dismiss()
            })
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json, .text],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                Haptics.error()
                onRestoreComplete(false)
                dismiss()
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let jsonString = try String(contentsOf: url, encoding: .utf8)
                let success = dataManager.importFromJSON(jsonString)
                if success {
                    Haptics.success()
                } else {
                    Haptics.error()
                }
                onRestoreComplete(success)
                dismiss()
            } catch {
                Haptics.error()
                onRestoreComplete(false)
                dismiss()
            }
        case .failure:
            Haptics.error()
            onRestoreComplete(false)
            dismiss()
        }
    }
}

struct RestoreSheetLegacy: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var showingDocumentPicker = false
    let onRestoreComplete: (Bool) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("restore_title")
                    .font(.headline)
                
                Text("restore_warning")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("restore_instructions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: { showingDocumentPicker = true }) {
                    Label("select_backup_file", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("restore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    // Start accessing security-scoped resource
                    guard url.startAccessingSecurityScopedResource() else {
                        Haptics.error()
                        onRestoreComplete(false)
                        dismiss()
                        return
                    }
                    
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    do {
                        let jsonString = try String(contentsOf: url, encoding: .utf8)
                        let success = dataManager.importFromJSON(jsonString)
                        if success {
                            Haptics.success()
                        } else {
                            Haptics.error()
                        }
                        onRestoreComplete(success)
                        dismiss()
                    } catch {
                        Haptics.error()
                        onRestoreComplete(false)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .text])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}
