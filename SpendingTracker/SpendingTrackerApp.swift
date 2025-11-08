import SwiftUI

@main
struct SpendingTrackerApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(localizationManager)
                .preferredColorScheme(dataManager.theme.colorScheme)
                .environment(\.locale, localizationManager.currentLanguage.localeIdentifier != nil ? Locale(identifier: localizationManager.currentLanguage.localeIdentifier!) : Locale.current)
                .id(localizationManager.currentLanguage)
        }
    }
}
