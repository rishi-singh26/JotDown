//
//  AppConstants.swift
//  JotDown
//
//  Created by Rishi Singh on 23/06/25.
//

import Foundation

class AppConstants {
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
        static let autoCheckForUpdates = "autoCheckForUpdates"
    }
}
