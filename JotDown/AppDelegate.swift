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
    var jotDownWindowController: NSWindowController?
    
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
    
    // MARK: - JotDown Window
    @objc func openJotDownWindow() {
        print("📝 Opening QuickPad Window...")
        
        if jotDownWindowController == nil {
            // Track pinned state
            var isPinnedToTop = false
            
            // Define toggle pin action
            let togglePinToTop: () -> Void = { [weak self] in
                guard let window = self?.jotDownWindowController?.window else { return }
                isPinnedToTop.toggle()
                
                if isPinnedToTop {
                    window.level = .floating
                    print("📌 Window pinned to top")
                } else {
                    window.level = .normal
                    print("📍 Window unpinned")
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
            window.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.setContentSize(NSSize(width: UserDefaultsManager.width, height: UserDefaultsManager.height))
            window.isReleasedWhenClosed = false
            window.center()
            
            // Make window translucent START
            window.isOpaque = false
            window.backgroundColor = .clear
            
            // Add NSVisualEffectView for translucency
            let visualEffectView = NSVisualEffectView()
            visualEffectView.blendingMode = .behindWindow
            visualEffectView.material = .hudWindow   // You can also try .underWindowBackground, .sidebar, .menu, etc.
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
        print("🛑 Closing QuickPad Window...")
        jotDownWindowController?.window?.performClose(nil)
    }
        
    @objc func jotDownWindowWillClose(_ notification: Notification) {
        print("🛑 QuickPad Window will close - cleaning up...")
        
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
        
        // Only hide if JotDown window is not open
        if jotDownWindowController == nil {
            hideFromDock()
        }
        
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
        
        let closeWindowItem = NSMenuItem(
            title: "Close Window",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        )
        closeWindowItem.target = nil
        appMenu.addItem(closeWindowItem)

        print("⌨️ Command + W shortcut registered")
        
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
