//
//  AppDelegate.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    
    var settingsWindowController: SettingsWindowController?
    var jotDownWindowController: NSWindowController?
    
    var updaterController: SPUStandardUpdaterController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // print("🚀 App did finish launching - AppDelegate working!")
        
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
    
    @objc func quitApp() {
        // print("👋 Quit app triggered")
        NSApp.terminate(nil)
    }
    
    @IBAction func checkForUpdates(_ sender: Any) {
        updaterController?.checkForUpdates(sender)
    }
}

// MARK: - Popover management
extension AppDelegate {
    private func setupStatusItem() {
        // print("📍 Setting up status item...")
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else {
            // print("❌ Failed to create status item button")
            return
        }
        
        // print("✅ Status item button created")
        
        // Configure button appearance
        button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: AppConstants.appName)
        button.action = #selector(togglePopover)
        button.target = self
        
        // Make sure it's visible
        statusItem.isVisible = true
        
        // print("🎯 Status item configured and visible")
        // print("📏 Button frame: \(button.frame)")
    }
    
    private func setupPopover() {
        // print("🎨 Setting up popover...")
        
        // Create popover with SwiftUI content
        popover = NSPopover()
        popover.contentSize = NSSize(width: AppConstants.width, height: AppConstants.height)
        popover.behavior = .transient
        popover.animates = true
        
        let quickPadView = QuickPadView(
            onQuit: { [weak self] in
                self?.quitApp()
            },
            openSettings: { [weak self] in
                self?.openSettingsWindow()
            }
        )
        
        popover.contentViewController = NSHostingController(rootView: quickPadView)
        // print("✅ Popover configured")
    }
    
    @objc func togglePopover() {
        // print("🖱️ Toggle popover called")
        
        guard let button = statusItem.button else {
            // print("❌ No status item button for popover")
            return
        }
        
        if popover.isShown {
            // print("📤 Closing popover")
            popover.performClose(nil)
        } else {
            // print("📥 Opening popover")
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

// MARK: - JotDown Window
extension AppDelegate {
    @objc func openJotDownWindow() {
        // print("📝 Opening QuickPad Window...")
        
        if jotDownWindowController == nil {
            // Track pinned state
            var isPinnedToTop = false
            
            // Define toggle pin action
            let togglePinToTop: () -> Void = { [weak self] in
                guard let window = self?.jotDownWindowController?.window else { return }
                isPinnedToTop.toggle()
                
                if isPinnedToTop {
                    window.level = .floating
                    // print("📌 Window pinned to top")
                } else {
                    window.level = .normal
                    // print("📍 Window unpinned")
                }
            }
            
            let quickPadView = QuickPadView(
                onQuit: { [weak self] in
                    self?.quitApp()
                },
                openSettings: { [weak self] in
                    self?.openSettingsWindow()
                },
                togglePin: togglePinToTop,
                isWindow: true,
            )
            
            let hostingController = NSHostingController(rootView: quickPadView)
            let window = NSWindow(
                contentViewController: hostingController
            )
            window.title = AppConstants.appName
            window.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.setContentSize(NSSize(width: AppConstants.width, height: AppConstants.height))
            window.isReleasedWhenClosed = false
            window.center()
            
            // Make window translucent START
            window.isOpaque = false
            window.backgroundColor = .clear
            
            // Add NSVisualEffectView for translucency
            let visualEffectView = NSVisualEffectView()
            visualEffectView.blendingMode = .behindWindow
            visualEffectView.material = .sidebar   // You can also try .underWindowBackground, .sidebar, .menu, etc.
            visualEffectView.state = .active
            
            // Add border around the no title window START
            visualEffectView.wantsLayer = true
            visualEffectView.layer?.borderWidth = 1
            visualEffectView.layer?.borderColor = NSColor.gray.withAlphaComponent(0.5).cgColor
            visualEffectView.layer?.cornerRadius = 12
            // Add border around the no title window END
            
            // Embed SwiftUI content inside visualEffectView
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.addSubview(hostingController.view)
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
            ])
            
            window.contentView = visualEffectView
            // Make window translucent END
            
            jotDownWindowController = NSWindowController(window: window)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(jotDownWindowWillClose(_:)),
                name: NSWindow.willCloseNotification,
                object: window
            )
            
            // Show app in dock when settings window opens
            showInDock()
        }
        
        jotDownWindowController?.showWindow(nil)
        jotDownWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func closeJotDownWindow() {
        // print("🛑 Closing QuickPad Window...")
        jotDownWindowController?.window?.performClose(nil)
    }
    
    @objc func jotDownWindowWillClose(_ notification: Notification) {
        // print("🛑 QuickPad Window will close - cleaning up...")
        
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.willCloseNotification,
            object: jotDownWindowController?.window
        )
        
        // Only hide if Settings window is not open
        if settingsWindowController == nil {
            hideFromDock()
        }
        
        jotDownWindowController = nil
    }
}

// MARK: - Settings Window management
extension AppDelegate {
    @objc func openSettingsWindow() {
        // print("⚙️ Opening Settings Window...")
        
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
        // print("🛑 Settings Window will close - hiding from dock...")
        
        // Remove observer
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.willCloseNotification,
            object: settingsWindowController?.window
        )
        
        // Only hide if JotDown window is not open
        if jotDownWindowController == nil {
            hideFromDock()
        }
        
        // Clean up the window controller
        settingsWindowController = nil
    }
    
    @objc func closeSettingsWindow() {
        // print("🛑 Closing Settings Window...")
        settingsWindowController?.window?.performClose(nil)
    }
}

// MARK: - Dock Visibility Management
extension AppDelegate {
    private func showInDock() {
        // print("🔍 Showing app in dock...")
        NSApp.setActivationPolicy(.regular)
    }
    
    private func hideFromDock() {
        // print("👻 Hiding app from dock...")
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupKeyboardShortcuts() {
        // Create the main menu
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        // Add Settings item (Command + ,)
        let settingsItem = NSMenuItem(title: "Preferences", action: #selector(openSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        appMenu.addItem(settingsItem)
        
        appMenu.addItem(NSMenuItem.separator())
        
        // Add Quit item (Command + Q)
        let quitItem = NSMenuItem(title: "Quit \(AppConstants.appName)", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        appMenu.addItem(quitItem)
        
        // Add Edit menu with standard shortcuts
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        
        // Standard edit menu items
        editMenu.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.addItem(NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z"))
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        
        // Add Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        
        // Standard window menu items
        windowMenu.addItem(NSMenuItem(title: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"))
        windowMenu.addItem(NSMenuItem(title: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        windowMenu.addItem(NSMenuItem.separator())
        
        // Custom window menu items for your app
        let openJotDownWindowItem = NSMenuItem(title: "Open \(AppConstants.appName) Window", action: #selector(openJotDownWindow), keyEquivalent: KeyboardShortcuts.Name.toggleJotDownWindow.rawValue)
        openJotDownWindowItem.target = self
        windowMenu.addItem(openJotDownWindowItem)
        
        let openSettingsWindowItem = NSMenuItem(title: "Open Settings Window", action: #selector(openSettingsWindow), keyEquivalent: ",")
        openSettingsWindowItem.target = self
        windowMenu.addItem(openSettingsWindowItem)
        
        // Tell NSApp to manage this as the window menu (enables automatic window list)
        NSApp.windowsMenu = windowMenu
        
        NSApp.mainMenu = mainMenu
        
        // Your existing keyboard shortcuts code...
        KeyboardShortcuts.onKeyUp(for: .toggleMenuBarPopup) { [self] in
            togglePopover()
        }
        
        KeyboardShortcuts.onKeyUp(for: .toggleJotDownWindow) { [self] in
            openJotDownWindow()
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
