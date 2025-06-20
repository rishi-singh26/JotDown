//
//  UserDefaultsManager.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import Foundation

class UserDefaultsManager {
    static let width = 600
    static let height = 450
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let quickPadDraft = "QuickPadDraft"
        static let launchAtLogin = "launchAtLogin"
        static let monospaced = "monospaced"
        static let fontSize = "fontSize"
    }
    
    private init() {}
    
    // MARK: - Draft
    
    static func saveDraft(_ text: String) {
        defaults.set(text, forKey: Keys.quickPadDraft)
    }
    
    static func loadDraft() -> String? {
        return defaults.string(forKey: Keys.quickPadDraft)
    }
    
    static func clearDraft() {
        defaults.removeObject(forKey: Keys.quickPadDraft)
    }
    
    // MARK: - <#Section Heading#>
    static func getLaunchAtLogin() -> Bool {
        defaults.bool(forKey: Keys.launchAtLogin)
    }
    
    static func setLaunchAtLogin(value: Bool) {
        defaults.set(value, forKey: Keys.launchAtLogin)
    }
    
    static func getMonoSpaced() -> Bool {
        defaults.bool(forKey: Keys.monospaced)
    }
    
    static func getFontSize() -> Double {
        defaults.double(forKey: Keys.fontSize)
    }
}
