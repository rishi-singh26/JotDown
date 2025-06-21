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

struct AboutView: View {
    @Environment(\.openURL) var openURL
    
    @State private var linkToOpen = ""
    @State private var showLinkOpenConfirmation = false
    
    var body: some View {
        ScrollView {
            MacCustomSection(header: "") {
                HStack {
                    Image("AppIconImage")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 15)
                    VStack(alignment: .leading) {
                        Text("TempBox")
                            .font(.largeTitle.bold())
                        Text("\(UserDefaultsManager.appName) v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                            .font(.callout)
                        Text("Developed by Rishi Singh")
                            .font(.callout)
                    }
                    Spacer()
                }
            }
            .padding(.top)
            
            MacCustomSection {
                VStack(alignment: .leading) {
                    Button {
                        showLinkConfirmation(url: "https://letterbird.co/tempbox")
                    } label: {
                        Label("Website", systemImage: "network")
                    }
                    .buttonStyle(.link)
                    
                    Divider()
                    
                    Button {
                        showLinkConfirmation(url: "https://letterbird.co/tempbox")
                    } label: {
                        Label("Contact Us", systemImage: "text.bubble")
                    }
                    .buttonStyle(.link)
                    
                    Divider()
                    
                    Button {
                        showLinkConfirmation(url: "https://letterbird.co/tempbox")
                    } label: {
                        Label("Privacy Policy", systemImage: "bolt.shield.fill")
                    }
                    .buttonStyle(.link)
                }
            }
            .padding(.bottom)
        }
        .confirmationDialog("Open Link?", isPresented: $showLinkOpenConfirmation, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                if let url = URL(string: linkToOpen) {
                    openURL(url)
                }
            }
        }, message: {
            Text(linkToOpen)
        })
        
    }
    
    func showLinkConfirmation(url: String) {
        linkToOpen = url
        showLinkOpenConfirmation.toggle()
    }
}

#Preview {
    AboutView()
}
