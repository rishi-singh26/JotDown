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

    /// Save or update note content with QuickPad ID
    static func saveOrUpdateNote(title: String, content: String) -> (Bool, String?) { // status, error
        let script = """
        tell application "Notes"
            try
                tell account "iCloud"
                    set folderName to "JotDown"
        
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
                    set noteBody to "<div>\(convertToNotesHTML(content))</div>"
                    
                    make new note at targetFolder with properties {name:noteName, body:noteBody}
                end tell
            on error errMsg
                display dialog "AppleScript Error: " & errMsg
            end try
        end tell
        """
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            let _ = appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript Error: \(error)")
                return (false, "AppleScript Error: \(error)")
            }
            return (true, nil)
        }
        print("⚠️ Unknown AppleScript failure during save")
        return (false, "Unknown error")
    }
    
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
    
    static private func convertToNotesHTML(_ text: String) -> String {
        let paragraphs = text.components(separatedBy: .newlines)
        let htmlParagraphs = paragraphs.map { line -> String in
            let escapedLine = line
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\r", with: "")
                .replacingOccurrences(of: "\t", with: "&nbsp;&nbsp;&nbsp;&nbsp;")
                .replacingOccurrences(of: "\n", with: "")
            return "<p>\(escapedLine)</p>"
        }
        return htmlParagraphs.joined()
    }
}

