//
//  Constants.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleMenuBarPopup = Self("toggleMenuBarPopup", default: .init(.j, modifiers: [.command, .shift]))
    static let toggleJotDownWindow = Self("toggleJotDownWindow", default: .init(.j, modifiers: [.command, .option]))
}
