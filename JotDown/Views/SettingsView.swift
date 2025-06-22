//
//  SettingsView.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var controller = AppController.shared
    
    let minFontSize = 10
    let maxFontSize = 30

    var body: some View {
        ScrollView {
            MacCustomSection {
                HStack(alignment: .center) {
                    Text("Launch at Login")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $controller.launchAtLogin)
                        .toggleStyle(.switch)
                        .help("Launch at Login")
                }
            }
            .padding(.top)
            
            MacCustomSection(header: "Editor Settings") {
                HStack(alignment: .center) {
                    Text("Text Size")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    
                    Stepper(value: $controller.fontSize, in: Double(minFontSize)...Double(maxFontSize), step: 1) {
                        HStack {
                            HStack(spacing: 0) {
                                Text("A")
                                    .font(.custom("small", size: 11))
                                Slider(value: $controller.fontSize, in: Double(minFontSize)...Double(maxFontSize), step: 1)
                                    .frame(width: 200, alignment: .trailing)
                                Text("A")
                                    .font(.custom("medium", size: 15))
                                    .padding(.leading, 6)
                            }
                            Text(String(format: "%.0f", controller.fontSize))
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
                
                Divider()
                
                HStack(alignment: .center) {
                    Text("Monospaced")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $controller.monospaced)
                        .toggleStyle(.switch)
                        .help("Monospaced font style")
                }
            }
            
            MacCustomSection(header: "\(UserDefaultsManager.appName) MenuBar Popup Settings") {
                HStack {
                    Text("Toggle Menubar Popup")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder("", name: .toggleMenuBarPopup)
                        .help("Toggle Menubar Popup")
                }
                
                Divider()
                
                HStack(alignment: .center) {
                    Text("Translucent Background")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $controller.isPopupTranslucent)
                        .toggleStyle(.switch)
                        .help("Translucent Background for the popup")
                }
            }
            MacCustomSection(header: "\(UserDefaultsManager.appName) Window Settings") {
                HStack {
                    Text("Toggle Window")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    KeyboardShortcuts.Recorder("", name: .toggleJotDownWindow)
                        .help("Toggle Window")
                }
                
                Divider()
                
                HStack(alignment: .center) {
                    Text("Translucent Background")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $controller.isWindowTranslucent)
                        .toggleStyle(.switch)
                        .help("Translucent Background for the window")
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    SettingsView()
}
