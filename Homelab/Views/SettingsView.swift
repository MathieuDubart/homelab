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
                Section(header: Text(LocalizedStringResource.serverConfiguration), footer:Text(LocalizedStringResource.cloudflareTunnelExempleUrl)) {
                    TextField(LocalizedStringResource.cloudflareTunnelExempleUrl, text: $glancesUrl)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                
                Section(header: Text(LocalizedStringResource.coolifyApi), footer:Text(LocalizedStringResource.generableInCoolifyInstance)) {
                    TextField(LocalizedStringResource.cloudflareTunnelExempleUrl, text: $coolifyUrl)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    
                    SecureField(LocalizedStringResource.apiToken, text: $coolifyToken)
                    
                }
                
                
                Section(header: Text(LocalizedStringResource.torboxStorage), footer: Text(LocalizedStringResource.apiTokenCanBeFoundOnTorbox)) {
                    SecureField(LocalizedStringResource.apiToken, text: $torboxToken)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text(LocalizedStringResource.cloudflareAccess), footer: Text(LocalizedStringResource.ifYouUseCloudflareAccess)) {
                    TextField(LocalizedStringResource.cfClientId, text: $cfClientId)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField(LocalizedStringResource.cfClientSecret, text: $cfClientSecret)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle(LocalizedStringResource.parameters)
        }
    }
}
