import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage = .auto {
        didSet {
            updateLocale()
        }
    }
    
    private var bundle: Bundle?
    
    private init() {
        updateLocale()
    }
    
    private func updateLocale() {
        if let localeIdentifier = currentLanguage.localeIdentifier,
           let path = Bundle.main.path(forResource: localeIdentifier, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = nil
        }
    }
    
    func localizedString(_ key: String) -> String {
        if let bundle = bundle {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return NSLocalizedString(key, comment: "")
    }
}

// Extension pour faciliter l'utilisation
extension String {
    func localized() -> String {
        return LocalizationManager.shared.localizedString(self)
    }
}

// View component pour texte localisé réactif
struct LocalizedText: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    let key: String
    
    var body: some View {
        Text(localizationManager.localizedString(key))
    }
}
