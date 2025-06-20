//
//  AppDelegate.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

// This should be your ONLY Swift file with @main
// Delete any other App.swift or ContentView.swift files

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    
    var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App did finish launching - AppDelegate working!")
        
        // Hide dock icon (this is crucial for menu bar apps)
        NSApp.setActivationPolicy(.accessory)
        
        // Setup keyboard shortcut
        setupKeyboardShortcuts()
        
        // Delay status item creation slightly to ensure menu bar is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupStatusItem()
            self.setupPopover()
        }
    }
    
    private func setupStatusItem() {
        print("📍 Setting up status item...")
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else {
            print("❌ Failed to create status item button")
            return
        }
        
        print("✅ Status item button created")
        
        // Configure button appearance
        button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "JotDown")
        button.action = #selector(togglePopover)
        button.target = self
        
        // Make sure it's visible
        statusItem.isVisible = true
        
        print("🎯 Status item configured and visible")
        print("📏 Button frame: \(button.frame)")
    }
    
    private func setupPopover() {
        print("🎨 Setting up popover...")
        
        // Create popover with SwiftUI content
        popover = NSPopover()
        popover.contentSize = NSSize(width: UserDefaultsManager.width, height: UserDefaultsManager.height)
        popover.behavior = .transient
        popover.animates = true
        
        let quickPadView = QuickPadView { [weak self] in
            self?.popover.performClose(nil)
        }
        
        popover.contentViewController = NSHostingController(rootView: quickPadView)
        print("✅ Popover configured")
    }
    
    @objc func togglePopover() {
        print("🖱️ Toggle popover called")
        
        guard let button = statusItem.button else {
            print("❌ No status item button for popover")
            return
        }
        
        if popover.isShown {
            print("📤 Closing popover")
            popover.performClose(nil)
        } else {
            print("📥 Opening popover")
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: - Settings Window
    @objc func openSettingsWindow() {
        print("⚙️ Opening Settings Window...")

        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        print("👋 Quit app triggered")
        NSApp.terminate(nil)
    }
    
    private func setupKeyboardShortcuts() {
        // Create the main menu
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
        
        // Create the App menu (the one named after your app)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        // Add Settings item (Command + ,)
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        appMenu.addItem(settingsItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        // Add Quit item (Command + Q)
        let quitTitle = "Quit JotDown"
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        appMenu.addItem(quitItem)
        
        print("⌨️ Command + , and Command + Q shortcuts registered")
    }
}

// MARK: - App Configuration
extension AppDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
