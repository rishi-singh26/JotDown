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
    static let appName = "JotDown"
    static let shortcutName = "JotDown Send to Notes"
    static let shortcutURL = "https://www.icloud.com/shortcuts/d31dafba93f742e68c9ff15c18bc70bc"
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let quickPadDraft = "QuickPadDraft"
        static let launchAtLogin = "launchAtLogin"
        static let monospaced = "monospaced"
        static let fontSize = "fontSize"
        static let windowTranslucent = "windowTranslucent"
        static let popupTranslucent = "popupTranslucent"
        static let shortcutVerified = "shortcutVerified"
        static let useShortcutToSave = "useShortcutToSave"
        static let notesPermissionStatus = "notesPermissionStatus"
    }
    
    private init() {}
    
    // MARK: - Draft
    
    static func saveDraft(_ text: String) {
        defaults.set(text, forKey: Keys.quickPadDraft)
    }
    
    static func loadDraft() -> String {
        return defaults.string(forKey: Keys.quickPadDraft) ?? ""
    }
    
    static func clearDraft() {
        defaults.removeObject(forKey: Keys.quickPadDraft)
    }
    
    // MARK: - Launch At Login
    static func getLaunchAtLogin() -> Bool {
        defaults.bool(forKey: Keys.launchAtLogin)
    }
    
    static func setLaunchAtLogin(value: Bool) {
        defaults.set(value, forKey: Keys.launchAtLogin)
    }
    
    // MARK: - Monospaced
    static func getMonoSpaced() -> Bool {
        defaults.bool(forKey: Keys.monospaced)
    }
    
    static func setMonoSpaced(value: Bool) {
        defaults.set(value, forKey: Keys.monospaced)
    }
    
    // MARK: - FontSize
    static func getFontSize() -> Double {
        defaults.double(forKey: Keys.fontSize)
    }
    
    static func setFontSize(value: Double) {
        defaults.set(value, forKey: Keys.fontSize)
    }
    
    // MARK: - Window Translucensy
    static func getWindowTranslucent() -> Bool {
        defaults.bool(forKey: Keys.windowTranslucent)
    }
    
    static func setWindowTranslucency(value: Bool) {
        defaults.set(value, forKey: Keys.windowTranslucent)
    }
    
    // MARK: - Popup Translucensy
    static func getPopupTranslucent() -> Bool {
        defaults.bool(forKey: Keys.popupTranslucent)
    }
    
    static func setPopupTranslucent(value: Bool) {
        defaults.set(value, forKey: Keys.popupTranslucent)
    }
    
    // MARK: - Shortcut Verification
    static func getShortcutVerified() -> Bool {
        defaults.bool(forKey: Keys.shortcutVerified)
    }
    
    static func setShortcutVerified(value: Bool) {
        defaults.set(value, forKey: Keys.shortcutVerified)
    }
    
    // MARK: - Use Shortcut to save
    static func getUseShortcutToSave() -> Bool {
        defaults.bool(forKey: Keys.useShortcutToSave)
    }
    
    static func setUseShortcutToSave(value: Bool) {
        defaults.set(value, forKey: Keys.useShortcutToSave)
    }
    
    // MARK: - Notes permission status
    static func getNotesPermission() -> Bool {
        defaults.bool(forKey: Keys.notesPermissionStatus)
    }
        
    static func setNotesPermission(value: Bool) {
        defaults.set(value, forKey: Keys.notesPermissionStatus)
    }
}
