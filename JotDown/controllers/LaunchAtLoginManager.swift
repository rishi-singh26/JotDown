//
//  LaunchAtLoginManager.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    
    func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
                print("✅ Registered for launch at login")
            } else {
                try SMAppService.mainApp.unregister()
                print("🚫 Unregistered from launch at login")
            }
        } catch {
            print("⚠️ Failed to change launch at login status: \(error)")
        }
    }
    
    func isLaunchAtLoginEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
    
    func initialSetup() {
        // At app launch, check if the app is set to launch at login and reflect the same in the settings
        let isEnabled = isLaunchAtLoginEnabled()
        AppController.shared.launchAtLogin = isEnabled;

    }
}

