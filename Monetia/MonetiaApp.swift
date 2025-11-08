import SwiftUI
import UIKit

// Haptic feedback helpers
struct Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

@main
struct MonetiaApp: App {
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
