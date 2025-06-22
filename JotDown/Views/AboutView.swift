//
//  AboutView.swift
//  JotDown
//
//  Created by Rishi Singh on 22/06/25.
//

import SwiftUI

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
                        Text(AppConstants.appName)
                            .font(.largeTitle.bold())
                        Text("\(AppConstants.appName) v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
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
                        showLinkConfirmation(url: "https://jotdown.rishisingh.in")
                    } label: {
                        Label("Website", systemImage: "network")
                    }
                    .buttonStyle(.link)
                    
                    Divider()
                    
                    Button {
                        showLinkConfirmation(url: "mailto:email@rishisingh.in")
                    } label: {
                        Label("Contact Us", systemImage: "text.bubble")
                    }
                    .buttonStyle(.link)
                    
                    Divider()
                    
                    Button {
                        showLinkConfirmation(url: "https://jotdown.rishisingh.in/privacy-policy.html")
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
