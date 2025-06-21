//
//  AppDelegate.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    
    var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 App did finish launching - AppDelegate working!")
        
        // Hide dock icon (this is crucial for menu bar apps)
        NSApp.setActivationPolicy(.accessory)
        
        // Close any default windows that might have been created
        for window in NSApp.windows {
            window.close()
        }
        
        // Setup keyboard shortcut
        setupKeyboardShortcuts()
        
        // Delay status item creation slightly to ensure menu bar is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupStatusItem()
            self.setupPopover()
        }
        
        LaunchAtLoginManager.shared.initialSetup()
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
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
        
        let quickPadView = QuickPadView(
            onClose: { [weak self] in
                self?.popover.performClose(nil)
            },
            onQuit: { [weak self] in
                self?.quitApp()
            },
            openSettings: { [weak self] in
                self?.openSettingsWindow()
            }
        )
        
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
            
            // Set up window close notification
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose(_:)),
                name: NSWindow.willCloseNotification,
                object: settingsWindowController?.window
            )
        }

        // Show app in dock when settings window opens
        showInDock()
        
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // explicitly order window to front regardless of state:
        settingsWindowController?.window?.orderFrontRegardless()
    }
    
    @objc func settingsWindowWillClose(_ notification: Notification) {
        print("🛑 Settings Window will close - hiding from dock...")
        
        // Remove observer
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.willCloseNotification,
            object: settingsWindowController?.window
        )
        
        // Hide app from dock when settings window closes
        hideFromDock()
        
        // Clean up the window controller
        settingsWindowController = nil
    }
    
    @objc func quitApp() {
        print("👋 Quit app triggered")
        NSApp.terminate(nil)
    }
    
    @objc func closeSettingsWindow() {
        print("🛑 Closing Settings Window...")
        settingsWindowController?.window?.performClose(nil)
    }
    
    // MARK: - Dock Visibility Management
    private func showInDock() {
        print("🔍 Showing app in dock...")
        NSApp.setActivationPolicy(.regular)
    }
    
    private func hideFromDock() {
        print("👻 Hiding app from dock...")
        NSApp.setActivationPolicy(.accessory)
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
        
        // Add Close Settings Window item (Command + W)
        let closeWindowItem = NSMenuItem(title: "Close Window", action: #selector(closeSettingsWindow), keyEquivalent: "w")
        closeWindowItem.target = self
        appMenu.addItem(closeWindowItem)

        print("⌨️ Command + W shortcut registered")
        
        KeyboardShortcuts.onKeyUp(for: .toggleMenuBarPopup) { [self] in
            togglePopover()
        }
        
        KeyboardShortcuts.onKeyUp(for: .toggleJotDownWindow) { [self] in
//            openSettingsWindow()
        }
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
