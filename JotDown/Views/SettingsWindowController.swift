//
//  SettingsWindowController.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {
    
    init() {
        let tabViewController = SettingsTabViewController()
        
        let window = NSWindow(contentViewController: tabViewController)
        window.title = "Settings"
        window.setContentSize(NSSize(width: 480, height: 520))
        window.minSize = NSSize(width: 480, height: 520)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.center()
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsTabViewController: NSTabViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabStyle = .toolbar
        
        addSettingsTab()
        addAboutTab()
    }
    
    private func addSettingsTab() {
        let settingsVC = NSHostingController(rootView: SettingsView())
        settingsVC.title = "Settings"
        
        let settingsTab = NSTabViewItem(viewController: settingsVC)
        settingsTab.label = "Settings"
        settingsTab.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Settings")
        addTabViewItem(settingsTab)
    }
    
    private func addAboutTab() {
        let aboutVC = NSHostingController(rootView: AboutView())
        aboutVC.title = "About"
        let aboutTab = NSTabViewItem(viewController: aboutVC)
        aboutTab.label = "About"
        aboutTab.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About")
        addTabViewItem(aboutTab)
    }
}
