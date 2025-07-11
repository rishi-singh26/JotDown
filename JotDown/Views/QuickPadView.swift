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
    
    let onQuit: () -> Void
    let openSettings: () -> Void
    var togglePin: () -> Void = {}
    var isWindow: Bool = false
    
    var textFont: Font {
        let fontSize = controller.fontSize
        let useMonospaced = controller.monospaced
        
        if useMonospaced {
            return .system(size: fontSize, design: .monospaced)
        }
        
        return .system(size: fontSize)
    }
    
    var background: Color {
        if isWindow {
            return controller.isWindowTranslucent ? .clear : Color(NSColor.textBackgroundColor)
        } else {
            return controller.isPopupTranslucent ? .clear : Color(NSColor.textBackgroundColor)
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
                HStack {
                    Spacer()
                    Text(AppConstants.appName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.top, 10)
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
                        Group {
                            Button("Quit  ⌘ Q") {
                                onQuit()
                            }
                            .buttonStyle(.borderless)
                            
                            Divider()
                                .frame(height: 15)
                        }
                    }
                    
                    Button("Preferences  ⌘ ,") {
                        openSettings()
                    }
                    .buttonStyle(.borderless)
                    
                    if isWindow {
                        Group {
                            Divider()
                                .frame(height: 15)
                            
                            Button("Pin/Unpin  ⌘ P") {
                                togglePin()
                            }
                            .keyboardShortcut("p", modifiers: [.command])
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Send to Notes  ⌘ S") {
                        sendToNotes()
                    }
                    .keyboardShortcut("s", modifiers: [.command])
                    .buttonStyle(.borderless)
                    .foregroundStyle(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 14)
                    .background(.accent)
                    .cornerRadius(8)
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
    
    private func sendToNotes() {
        let content = controller.noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else {
            statusMessage = .nothingToSave
            messageColor = .orange
            return
        }
        
        // First, request permission by running a simple AppleScript
        if controller.hasNotesPermission {
            saveNote(content: content)
        } else {
            requestPermissionAndSaveNote(content: content)
        }
    }
    
    private func requestPermissionAndSaveNote(content: String) {
        isLoading = true
        statusMessage = .requestingPermission
        messageColor = .blue
        
        AppleScriptManager.requestNotesPermission { [self] success in
            self.isLoading = false
            if success {
                DispatchQueue.main.async {
                    controller.hasNotesPermission = true
                }
                self.saveNote(content: content)
            } else {
                self.statusMessage = .permissionDenied
                self.messageColor = .red
                
                // Show instructions for manual permission setup
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showPermissionInstructions()
                }
            }
        }
    }
    
    private func saveNote(content: String) {
        self.statusMessage = .saving
        AppleScriptManager.saveNote(title: "", content: content, withShortcut: controller.useShortcutToSave, useMonoSpaced: controller.monospaced) { status, statusCode, error in
            
            if status == true && error == nil {
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
            
            // Handle status code
            self.handleStatusCode(statusCode)
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
        4. Find "\(AppConstants.appName)" in the list
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
    
    private func handleStatusCode(_ code: Int) {
        switch code {
        case 0:
            print("Permission Denied")
            break
        case 1:
            print("Error while saving through AppleScript")
            break
        case 2:
            print("Error while saving through Shortcut and ERROR with AppleScript")
            break
        case 3:
            print("Error while saving through Shortcut and SUCCESS with AppleScript")
            break
        case 4:
            print("Success")
            break
        default:
            break
        }
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

