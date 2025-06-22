//
//  ShortcutsSetupView.swift
//  JotDown
//
//  Created by Rishi Singh on 22/06/25.
//

import SwiftUI

struct ShortcutsSetupView: View {
    @Environment(\.openURL) var openURL
    @ObservedObject var controller = AppController.shared
    
    var body: some View {
        ScrollView {
            MacCustomSection {
                VStack(alignment: .leading) {
                    Text("To avoid opening Apple Notes each time you send a note, complete the Shortcuts setup.")
                        .padding(.bottom, 8)
                    Text("Monospaced font style will not be maintained when Sending to Notes with shortcut.")
                    Divider()
                }
            }
            .padding(.top)
            
            MacCustomSection {
                VStack(alignment: .leading) {
                    Text("Step 1. Add this shortcut to your Shortcuts app. Do not change the shortcut name.")
                    HStack {
                        Spacer()
                        Button {
                            if let url = URL(string: UserDefaultsManager.shortcutURL) {
                                openURL(url)
                            }
                        } label: {
                            Text("Add Shortcut")
                        }
                    }
                }
            }
            
            MacCustomSection(footer: controller.isShortcutVerified ? "The Shortcuts setup has been verified. You can now send your notes to Apple Notes in the background." : "") {
                VStack(alignment: .leading) {
                    Text("Step 2. Verify that JotDown can find and execute the shortcut.")
                    HStack {
                        Text(controller.isShortcutVerified ? "Verified" : "Verification Pending")
                            .foregroundStyle(controller.isShortcutVerified ? Color.green : Color.yellow)
                        
                        Spacer()
                        
                        Button {
                            DispatchQueue.main.async {
                                let shortcutValue = "JotDown shortcut verification note"
                                let (status, error) = AppleScriptManager.saveNoteWithShortcut(
                                    name: UserDefaultsManager.shortcutName,
                                    with: shortcutValue
                                )
                                controller.isShortcutVerified = error == nil && status
                            }
                        } label: {
                            Text(controller.isShortcutVerified ? "Verify again" : "Verify")
                        }
                    }
                }
            }
            
            if controller.isShortcutVerified {
                MacCustomSection(footer: "Monospaced font style will not be maintained when Sending to Notes with shortcut.") {
                    HStack(alignment: .center) {
                        Text("Use shortcut to send to Notes")
                            .frame(width: 200, alignment: .leading)
                        Spacer()
                        Toggle("", isOn: $controller.useShortcutToSave)
                            .disabled(!controller.isShortcutVerified)
                            .toggleStyle(.switch)
                            .help("Use shortcut to send to Notes")
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ShortcutsSetupView()
}
