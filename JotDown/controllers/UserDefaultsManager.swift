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
        static let currentNoteTitle = "QuickPadCurrentNoteTitle"
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
    
    // MARK: - Current Note Title
    
    static func saveCurrentNoteTitle(_ title: String) {
        defaults.set(title, forKey: Keys.currentNoteTitle)
    }
    
    static func loadCurrentNoteTitle() -> String? {
        return defaults.string(forKey: Keys.currentNoteTitle)
    }
    
    static func clearCurrentNoteTitle() {
        defaults.removeObject(forKey: Keys.currentNoteTitle)
    }
}
