//
//  QuickPadView.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import SwiftUI

struct QuickPadView: View {
    @State private var noteText: String = ""
    @State private var statusMessage: String = "Ready to write..."
    @State private var messageColor: Color = .secondary
    @State private var isLoading: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
            
            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                ScrollView {
                    TextEditor(text: $noteText)
                        .focused($isTextFieldFocused)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .onAppear {
                            loadDraft()
                            isTextFieldFocused = true
                        }
                        .onChange(of: noteText) { _, newValue in
                            saveDraft()
                            updateWordCount()
                        }
                }
                .background(Color(NSColor.textBackgroundColor))
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
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(messageColor)
                    
                    Spacer()
                    
                    Text("\(wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    Button("Clear") {
                        clearText()
                    }
                    .buttonStyle(.bordered)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Copy") {
                        copyToClipboard()
                    }
                    .buttonStyle(.bordered)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                    
                    Button("Save to Notes") {
                        saveToNotes()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: CGFloat(UserDefaultsManager.width), height: CGFloat(UserDefaultsManager.width))
//        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var wordCount: Int {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
    
    private func updateWordCount() {
        let count = wordCount
        if count == 0 {
            statusMessage = "Ready to write..."
            messageColor = .secondary
        } else {
            statusMessage = "Typing..."
            messageColor = .blue
        }
    }
    
    private func copyToClipboard() {
        let content = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else {
            statusMessage = "Nothing to copy"
            messageColor = .orange
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        
        statusMessage = "Copied to clipboard!"
        messageColor = .green
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            statusMessage = "Ready to write..."
            messageColor = .secondary
        }
    }
    
    private func clearText() {
        noteText = ""
        statusMessage = "Cleared"
        messageColor = .orange
        saveDraft()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            statusMessage = "Ready to write..."
            messageColor = .secondary
        }
    }
    
    private func saveToNotes() {
        let content = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else {
            statusMessage = "Nothing to save"
            messageColor = .orange
            return
        }
        
        isLoading = true
        statusMessage = "Requesting permission..."
        messageColor = .blue
        
        // First, request permission by running a simple AppleScript
        requestNotesPermission { [self] success in
//            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.statusMessage = "Saving..."
                    self.performSaveToNotes(content: content)
                } else {
                    self.isLoading = false
                    self.statusMessage = "Permission denied - Open System Settings"
                    self.messageColor = .red
                    
                    // Show instructions for manual permission setup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.showPermissionInstructions()
                    }
                }
            }
        }
    }
    
    private func requestNotesPermission(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Simple permission request script
            let permissionScript = """
            tell application "Notes"
                try
                    get name of first note
                    return "permission_granted"
                on error
                    return "permission_denied"
                end try
            end tell
            """
            
            var error: NSDictionary?
            if let script = NSAppleScript(source: permissionScript) {
                let result = script.executeAndReturnError(&error)
                let success = (error == nil)
                completion(success)
            } else {
                completion(false)
            }
        }
    }
    
    private func performSaveToNotes(content: String) {
        let noteTitle = createNoteTitle(from: content)
        
        let appleScript = """
        tell application "Notes"
            activate
            try
                tell account "iCloud"
                    tell folder "Notes"
                        set newNote to make new note with properties {name:"\(escapeAppleScriptString(noteTitle))", body:"\(escapeAppleScriptString(content))"}
                    end tell
                end tell
            on error
                set newNote to make new note with properties {body:"\(escapeAppleScriptString(content))"}
            end try
        end tell
        """
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            
            if let script = NSAppleScript(source: appleScript) {
                let result = script.executeAndReturnError(&error)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if error == nil {
                        self.statusMessage = "Saved to Notes!"
                        self.messageColor = .green
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.noteText = ""
                            self.saveDraft()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.statusMessage = "Ready to write..."
                                self.messageColor = .secondary
                            }
                        }
                    } else {
                        self.statusMessage = "Save failed - Try manual setup"
                        self.messageColor = .red
                        print("AppleScript Error: \(error!)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.showPermissionInstructions()
                        }
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
        
        statusMessage = "Ready to write..."
        messageColor = .secondary
    }
    
    private func createNoteTitle(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if firstLine.isEmpty {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "Quick Note - \(formatter.string(from: Date()))"
        }
        
        let maxLength = 50
        if firstLine.count > maxLength {
            return String(firstLine.prefix(maxLength - 3)) + "..."
        }
        
        return firstLine
    }
    
    private func escapeAppleScriptString(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
    
    private func saveDraft() {
        UserDefaultsManager.saveDraft(noteText)
    }
    
    private func loadDraft() {
        if let draft = UserDefaultsManager.loadDraft() {
            noteText = draft
        }
    }
}

