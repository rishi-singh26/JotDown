//
//  SettingsView.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @AppStorage(UserDefaultsManager.Keys.launchAtLogin) private var launchAtLogin = false
    @AppStorage(UserDefaultsManager.Keys.monospaced) private var monospaced = false
    @AppStorage(UserDefaultsManager.Keys.fontSize) private var fontSize: Double = 15.0
    @AppStorage(UserDefaultsManager.Keys.windowTranslucent) private var isWindowTranslucent = false
    @AppStorage(UserDefaultsManager.Keys.popupTranslucent) private var isPopupTranslucent = false
    
    let minFontSize = 10
    let maxFontSize = 30

    var body: some View {
        ScrollView {
            MacCustomSection {
                HStack(alignment: .center) {
                    Text("Launch at Login")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: newValue)
                        }
                        .toggleStyle(.switch)
                        .help("Launch at Login")
                }
            }
            .padding(.top)
            
            MacCustomSection(header: "JotDown MenuBar Popup Settings") {
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
                    Toggle("", isOn: $isPopupTranslucent)
                        .toggleStyle(.switch)
                        .help("Translucent Background for the popup")
                }
            }
            MacCustomSection(header: "JotDown Window Settings") {
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
                    Toggle("", isOn: $isWindowTranslucent)
                        .toggleStyle(.switch)
                        .help("Translucent Background for the window")
                }
            }
            
            MacCustomSection {
                HStack(alignment: .center) {
                    Text("Text Size")
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    
                    Stepper(value: $fontSize, in: Double(minFontSize)...Double(maxFontSize), step: 1) {
                        HStack {
                            HStack(spacing: 0) {
                                Text("A")
                                    .font(.custom("small", size: 11))
                                Slider(value: $fontSize, in: Double(minFontSize)...Double(maxFontSize), step: 1)
                                    .frame(width: 200, alignment: .trailing)
                                Text("A")
                                    .font(.custom("medium", size: 15))
                                    .padding(.leading, 6)
                            }
                            Text(String(format: "%.0f", fontSize))
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
                
                Divider()
                
                HStack(alignment: .center) {
                    Text("Monospaced")
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $monospaced)
                        .toggleStyle(.switch)
                        .help("Monospaced font style")
                }
            }
            .padding(.bottom)
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About JotDown")
                .font(.largeTitle)
                .bold()
            
            Text("Version 1.0")
            Text("Created by Rishi Singh")

            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
