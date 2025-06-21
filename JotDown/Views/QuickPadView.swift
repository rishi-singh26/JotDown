//
//  QuickPadView.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import SwiftUI

enum StatusMessage: String {
    case readyToWrite = "Ready to write..."
    case typing = "Typing..."
    case nothingToCopy = "Nothing to copy"
    case copiedToClipboard = "Copied to clipboard!"
    case cleared = "Cleared"
    case nothingToSave = "Nothing to save"
    case requestingPermission = "Requesting permission..."
    case saving = "Saving..."
    case savedToNotes = "Saved to Notes!"
    case saveFailed = "Save failed - Try manual setup"
    case permissionDenied = "Permission denied - Open System Settings"
}

struct QuickPadView: View {
    @ObservedObject var controller = AppController.shared
    
    @State private var statusMessage: StatusMessage = .readyToWrite
    @State private var messageColor: Color = .secondary
    @State private var isLoading: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var onClose: () -> Void = {}
    let onQuit: () -> Void
    let openSettings: () -> Void
    var togglePin: () -> Void = {}
    var isWindow: Bool = false
    
    var textFont: Font {
        let fontSize = UserDefaultsManager.getFontSize()
        let useMonospaced = UserDefaultsManager.getMonoSpaced()
        
        if useMonospaced {
            return .system(size: fontSize, design: .monospaced)
        }
        
        return .system(size: fontSize)
    }
    
    var background: Color {
        if isWindow {
            return UserDefaultsManager.getWindowTranslucent() ? .clear : Color(NSColor.textBackgroundColor)
        } else {
            return UserDefaultsManager.getPopupTranslucent() ? .clear : Color(NSColor.textBackgroundColor)
        }
    }
    
    private var isNoteEmpty: Bool {
        controller.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var wordCount: Int {
        controller.noteText.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            if !isWindow {
                Group {
                    HStack {
                        Text("JotDown")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            onClose()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Close")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    Divider()
                }
            }
            
            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                ScrollView {
                    TextEditor(text: $controller.noteText)
                        .focused($isTextFieldFocused)
                        .font(textFont)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .onAppear {
                            isTextFieldFocused = true
                        }
                        .onChange(of: controller.noteText) { _, newValue in
                            updateWordCount()
                        }
                }
                .background(background)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Status and Actions
            VStack(spacing: 12) {
                HStack {
                    Text(statusMessage.rawValue)
                        .font(.caption)
                        .foregroundColor(messageColor)
                    
                    Spacer()
                    
                    Text("\(wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    if !isWindow {
                        Button("Quit  ⌘ Q") {
                            onQuit()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button("Preferences  ⌘ ,") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                    
                    if isWindow {
                        Button("Pin/Unpin  ⌘ P") {
                            togglePin()
                        }
                        .keyboardShortcut("p", modifiers: [.command])
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button("Clear  ⌘ K") {
                        clearText()
                    }
                    .keyboardShortcut("k", modifiers: [.command])
                    .buttonStyle(.bordered)
                    .disabled(isNoteEmpty)
                    
                    Button("Copy  ⌘ C") {
                        copyToClipboard()
                    }
                    .keyboardShortcut("c", modifiers: [.command])
                    .buttonStyle(.bordered)
                    .disabled(isNoteEmpty)
                    
                    Button("Save to Notes") {
                        saveToNotes()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isNoteEmpty || isLoading)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private func selectAllText() {
        // For TextEditor, we can use NSApp to send the select all command
        if let window = NSApp.keyWindow {
            window.makeFirstResponder(window.firstResponder)
            NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
        }
    }
    
    private func updateWordCount() {
        let count = wordCount
        if count == 0 {
            statusMessage = .readyToWrite
            messageColor = .secondary
        } else {
            statusMessage = .typing
            messageColor = .blue
        }
    }
    
    private func copyToClipboard() {
        let content = controller.noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else {
            statusMessage = .nothingToCopy
            messageColor = .orange
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        
        statusMessage = .copiedToClipboard
        messageColor = .green
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            statusMessage = .readyToWrite
            messageColor = .secondary
        }
    }
    
    private func saveToNotes() {
        let content = controller.noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else {
            statusMessage = .nothingToSave
            messageColor = .orange
            return
        }
        
        isLoading = true
        statusMessage = .requestingPermission
        messageColor = .blue
        
        // First, request permission by running a simple AppleScript
        AppleScriptManager.requestNotesPermission { [self] success in
//            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.statusMessage = .saving
                    let (status, error) = AppleScriptManager.saveNote(title: "", content: content, useMonoSpaced: controller.monospaced)
                    
                    self.isLoading = false
                    
                    if status == true {
                        self.statusMessage = .savedToNotes
                        self.messageColor = .green
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            controller.noteText = ""
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.statusMessage = .readyToWrite
                                self.messageColor = .secondary
                            }
                        }
                        
                    } else {
                        self.statusMessage = .saveFailed
                        self.messageColor = .red
                        print("AppleScript Error: \(error!)")
                    }
                } else {
                    self.isLoading = false
                    self.statusMessage = .permissionDenied
                    self.messageColor = .red
                    
                    // Show instructions for manual permission setup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.showPermissionInstructions()
                    }
                }
            }
        }
    }
    
    private func showPermissionInstructions() {
        let alert = NSAlert()
        alert.messageText = "Notes Permission Required"
        alert.informativeText = """
        To save notes, please grant permission:
        
        1. Open System Settings
        2. Go to Privacy & Security
        3. Click on "Automation"
        4. Find "JotDown" in the list
        5. Check the box next to "Notes"
        
        Then try saving again.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "OK")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open System Settings to Privacy & Security
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                NSWorkspace.shared.open(url)
            }
        }
        
        statusMessage = .readyToWrite
        messageColor = .secondary
    }
    
    private func clearText() {
        controller.noteText = ""
        statusMessage = .cleared
        messageColor = .orange
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            statusMessage = .readyToWrite
            messageColor = .secondary
        }
    }
}

