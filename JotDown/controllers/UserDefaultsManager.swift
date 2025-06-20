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
    
    private enum Keys {
        static let quickPadDraft = "QuickPadDraft"
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
}
