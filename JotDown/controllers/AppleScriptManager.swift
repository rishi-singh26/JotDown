//
//  AppleScriptManager.swift
//  JotDown
//
//  Created by Rishi Singh on 19/06/25.
//

import Foundation
import Cocoa

class AppleScriptManager {

    private init() {}
    
    // MARK: - Save Note Flow
    /// Status Codes
    /// 0 => Success
    /// 1 => Save with apple script ERROR
    /// 2 => Shortcut permission ERROR and ERROR with apple script error
    /// 3 => Shortcut permission ERROR and SUCCESS with apple script
    static func saveNote(title: String, content: String, withShortcut: Bool, useMonoSpaced: Bool = false, completion: @escaping (Bool, Int, String?) -> Void) {
        DispatchQueue.main.async {
            if withShortcut {
                // Save with shortcut
                let (status, error) = saveNoteWithShortcut(name: AppConstants.shortcutName, with: content, useMonoSpaced: useMonoSpaced)
                // On success, complete
                if error == nil && status {
                    completion(status, 0, error)
                } else {
                    // On error (Shortcut does not exist or any other), try with AppleScript
                    let (status, error) = saveNoteWithAppleScript(title: title, content: content, useMonoSpaced: useMonoSpaced)
                    completion(status, status ? 3 : 2, error)
                }
            } else {
                // Save with AppleScript
                let (status, error) = saveNoteWithAppleScript(title: title, content: content, useMonoSpaced: useMonoSpaced)
                completion(status, status ? 0 : 1, error)
            }
        }
    }
    
    
    // MARK: - Run Shortcut with input
    /// Save note to Apple notes application with a shortcut
    /// It will try to run the shortcut with the shortcut name provided in the parameter with the note provided in the parameter
    static func saveNoteWithShortcut(name: String, with value: String, useMonoSpaced: Bool = false) -> (Bool, String?) { // status, error
        let script = """
        set myText to "\(value)"
        set shortcutName to "\(name)"
        set shortcutExists to false
        
        try
            tell application "Shortcuts Events"
                run shortcut shortcutName with input myText
            end tell
            set shortcutExists to true
        on error
            set shortcutExists to false
        end try
        
        if shortcutExists then
            return "Success"
        else
            return "Error"
        end if
        """
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            let response = appleScript.executeAndReturnError(&error)
            if let error = error {
                // print("AppleScript Error: \(error)")
                return (false, "AppleScript Error: \(error)")
            }
            if response.stringValue == "Error" {
                // print("AppleScript Error")
                return (false, "AppleScript Error")
            }
            return (true, nil)
        }
        // print("⚠️ Unknown AppleScript failure during save")
        return (false, "Unknown error")
    }
    
    
    // MARK: - Save to Apple Notes with AppleScript
    /// Save or update note content with QuickPad ID
    static func saveNoteWithAppleScript(title: String, content: String, useMonoSpaced: Bool = false) -> (Bool, String?) { // status, error
        let script = """
        tell application "Notes"
            try
                tell account "iCloud"
                    set folderName to "\(AppConstants.appName)"
        
                    -- Check if folder exists
                    set folderExists to false
                    repeat with f in folders
                        if name of f is folderName then
                            set folderExists to true
                            exit repeat
                        end if
                    end repeat
        
                    if folderExists then
                        set targetFolder to folder folderName
                    else
                        set targetFolder to make new folder with properties {name:folderName}
                    end if
                    
                    set noteName to "\(escape(title))"
                    set noteBody to "<div>\(convertToNotesHTML(content, useMonoSpaced: useMonoSpaced))</div>"
                    
                    make new note at targetFolder with properties {name:noteName, body:noteBody}
                end tell
            on error errMsg
                display dialog "JotDown Error: " & errMsg
            end try
        end tell
        """
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            let _ = appleScript.executeAndReturnError(&error)
            if let error = error {
                // print("AppleScript Error: \(error)")
                return (false, "AppleScript Error: \(error)")
            }
            return (true, nil)
        }
        // print("⚠️ Unknown AppleScript failure during save")
        return (false, "Unknown error")
    }
    
    
    // MARK: - Request AppleScript permission
    static func requestNotesPermission(completion: @escaping (Bool) -> Void) {
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
                let _ = script.executeAndReturnError(&error)
                let success = (error == nil)
                completion(success)
            } else {
                completion(false)
            }
        }
    }
    
    
    /// Escape AppleScript string
    static private func escape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")

    }
    
    
    static private func convertToNotesHTML(_ text: String, useMonoSpaced: Bool) -> String {
        let paragraphs = text.components(separatedBy: .newlines)
        let htmlParagraphs = paragraphs.map { line -> String in
            let escapedLine = line
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "\t", with: "&nbsp;&nbsp;&nbsp;&nbsp;")
                .replacingOccurrences(of: "\n", with: "")
            return useMonoSpaced ? "<p><code>\(escapedLine)</code></p>" : "<p>\(escapedLine)</p>"
        }
        return htmlParagraphs.joined()
    }
}

