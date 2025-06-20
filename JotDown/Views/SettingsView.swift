//
//  SettingsView.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

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
        }
        .frame(width: 400, height: 300)
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
