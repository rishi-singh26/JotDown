//
//  SettingsView.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("exampleSetting") var exampleSetting: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.largeTitle)
                .bold()

            Toggle("Example Setting", isOn: $exampleSetting)

            Spacer()
        }
        .padding()
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
