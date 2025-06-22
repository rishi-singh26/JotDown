//
//  AppController.swift
//  JotDown
//
//  Created by Rishi Singh on 21/06/25.
//

import Foundation
import Combine
import SwiftUI

class AppController: ObservableObject {
    static let shared = AppController() // Singleton instance
    
    // MARK: - Note text
    @Published var noteText: String {
        didSet {
            UserDefaultsManager.saveDraft(noteText)
        }
    }
    
    // MARK: - Settings properties
    @Published var launchAtLogin: Bool {
        didSet {
            LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: launchAtLogin) // update launch at login settings
            UserDefaultsManager.setLaunchAtLogin(value: launchAtLogin)
        }
    }
    
    @Published var monospaced: Bool {
        didSet {
            UserDefaultsManager.setMonoSpaced(value: monospaced)
        }
    }
    
    @Published var fontSize: Double {
        didSet {
            UserDefaultsManager.setFontSize(value: fontSize)
        }
    }
    
    @Published var isWindowTranslucent: Bool {
        didSet {
            UserDefaultsManager.setWindowTranslucency(value: isWindowTranslucent)
        }
    }
    
    @Published var isPopupTranslucent: Bool {
        didSet {
            UserDefaultsManager.setPopupTranslucent(value: isPopupTranslucent)
        }
    }
    
    // MARK: - Shortcut setup properties
    @Published var isShortcutVerified: Bool {
        didSet {
            UserDefaultsManager.setShortcutVerified(value: isShortcutVerified)
        }
    }
    
    @Published var useShortcutToSave: Bool {
        didSet {
            UserDefaultsManager.setUseShortcutToSave(value: useShortcutToSave)
        }
    }
    
    // MARK: - Notes permission setup
    @Published var hasNotesPermission: Bool {
        didSet {
            UserDefaultsManager.setNotesPermission(value: hasNotesPermission)
        }
    }
    
    private init() {
        // Initialize from UserDefaults
        self.noteText = UserDefaultsManager.loadDraft()
        self.launchAtLogin = UserDefaultsManager.getLaunchAtLogin()
        self.monospaced = UserDefaultsManager.getMonoSpaced()
        self.fontSize = UserDefaultsManager.getFontSize()
        self.isWindowTranslucent = UserDefaultsManager.getWindowTranslucent()
        self.isPopupTranslucent = UserDefaultsManager.getPopupTranslucent()
        self.isShortcutVerified = UserDefaultsManager.getShortcutVerified()
        self.useShortcutToSave = UserDefaultsManager.getUseShortcutToSave()
        self.hasNotesPermission = UserDefaultsManager.getNotesPermission()
    }
}

