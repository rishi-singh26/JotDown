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
    @AppStorage(AppConstants.Keys.quickPadDraft)
    var noteText: String = ""
    
    // MARK: - Settings properties
    @AppStorage(AppConstants.Keys.launchAtLogin)
    var launchAtLogin: Bool = false {
        didSet {
            LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: launchAtLogin)
        }
    }
    
    @AppStorage(AppConstants.Keys.monospaced)
    var monospaced: Bool = false
    
    @AppStorage(AppConstants.Keys.fontSize)
    var fontSize: Double = 15.0
    
    @AppStorage(AppConstants.Keys.windowTranslucent)
    var isWindowTranslucent: Bool = false
    
    @AppStorage(AppConstants.Keys.popupTranslucent)
    var isPopupTranslucent: Bool = false
    
    // MARK: - Shortcut setup properties
    @AppStorage(AppConstants.Keys.shortcutVerified)
    var isShortcutVerified: Bool = false {
        didSet {
            if isShortcutVerified == false {
                useShortcutToSave = false
            }
        }
    }
    
    @AppStorage(AppConstants.Keys.useShortcutToSave)
    var useShortcutToSave: Bool = false
    
    // MARK: - AppleScript permission to Apple Notes setup
    @AppStorage(AppConstants.Keys.notesPermissionStatus)
    var hasNotesPermission: Bool = false
    
    // MARK: - Auto check for updates setup
    @AppStorage(AppConstants.Keys.autoCheckForUpdates)
    var autoCheckForUpdates: Bool = true
    
    private init() {}
}
