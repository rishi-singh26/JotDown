//
//  MacCustomSection.swift
//  JotDown
//
//  Created by Rishi Singh on 20/06/25.
//

import SwiftUI

struct MacCustomSection<Content: View>: View {
    let header: String?
    let footer: String?
    let content: Content
    
    init(
        header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let safeHeader = header {
                Text(safeHeader)
                    .font(.caption2)
                    .textCase(.uppercase)
                    .padding([.top, .horizontal])
                    .padding(.horizontal)
            }
            GroupBox {
                VStack {
                    content
                }
                .padding(6)
            }
            .padding(.horizontal)
            if let safeFooter = footer {
                Text(safeFooter)
                    .font(.caption2)
                    .padding(.horizontal)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MacCustomSection(header: "", footer: "") {
        Label("Privacy Policy", systemImage: "bolt.shield")
    }
}
