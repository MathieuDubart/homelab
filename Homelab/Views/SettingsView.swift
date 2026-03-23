//
//  SettingsView.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("glances_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var glancesUrl: String = "https://"
    @AppStorage("coolify_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyToken: String = ""
    @AppStorage("coolify_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyUrl: String = "https://"
    @AppStorage("torbox_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
        private var torboxToken: String = ""
    
    @AppStorage("cf_client_id", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
        private var cfClientId: String = ""
    @AppStorage("cf_client_secret", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
        private var cfClientSecret: String = ""
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading) {
                            Text("Glances API")
                                .font(.subheadline.bold())
                            TextField("https://stats.mondomaine.com", text: $glancesUrl)
                                .font(.system(.caption, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                    }
                } header: {
                    Text("mainServer")
                } footer: {
                    Text("urlMustIncludeHttps")
                }
                
                Section {
                    SettingsRow(icon: "shippingbox.fill", color: .orange, title: String(localized: "serverConfiguration")) {
                        TextField("https://app.coolify.io", text: $coolifyUrl)
                            .font(.system(.caption, design: .monospaced))
                            .textInputAutocapitalization(.never)
                    }
                    
                    SettingsRow(icon: "key.fill", color: .orange, title: String(localized: "apiToken")) {
                        SecureField("Bearer Token", text: $coolifyToken)
                            .font(.system(.caption, design: .monospaced))
                    }
                } header: {
                    Text("coolifyApi")
                } footer: {
                    Text("generableInCoolifyInstance")
                }
                
                Section {
                    SettingsRow(icon: "person.badge.shield.checkmark.fill", color: .orange, title: String(localized: "cfClientId")) {
                        TextField("CF-Access-Client-Id", text: $cfClientId)
                    }
                    
                    SettingsRow(icon: "key.fill", color: .orange, title: String(localized: "cfClientSecret")) {
                        SecureField("CF-Access-Client-Secret", text: $cfClientSecret)
                    }
                } header: {
                    Text("cloudflareAccess")
                } footer: {
                    Text("ifYouUseCloudflareAccess")
                }
                
                Section {
                    SettingsRow(icon: "square.stack.fill", color: .purple, title: String(localized: "apiToken")) {
                        SecureField("Token TorBox", text: $torboxToken)
                    }
                } header: {
                    Text("cloudStorage")
                }
                
                Section {
                    HStack {
                        Text("version")
                        Spacer()
                        Text("1.2.0-stable")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/MathieuDubart/homelab")!) {
                        Label(String(localized: "sourceCode"), systemImage: "terminal.fill")
                    }
                } header: {
                    Text("about")
                }
            }
            .navigationTitle(String(localized: "settings"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
