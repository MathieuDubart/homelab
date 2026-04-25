// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  SettingsView.swift
//  Homelab
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("glances_url",     store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var glancesUrl: String = "https://"
    @AppStorage("coolify_token",   store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyToken: String = ""
    @AppStorage("coolify_url",     store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyUrl: String = "https://"
    @AppStorage("torbox_token",    store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var torboxToken: String = ""
    @AppStorage("cf_client_id",    store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var cfClientId: String = ""
    @AppStorage("cf_client_secret",store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var cfClientSecret: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                section(title: "mainServer", tint: Palette.electric,
                        footer: "urlMustIncludeHttps") {
                    field(icon: "server.rack", tint: Palette.electric,
                          label: "Glances API") {
                        TextField("https://stats.mondomaine.com", text: $glancesUrl)
                            .textFieldStyle()
                    }
                }

                section(title: "coolifyApi", tint: Palette.solar,
                        footer: "generableInCoolifyInstance") {
                    field(icon: "shippingbox.fill", tint: Palette.solar,
                          label: "serverConfiguration") {
                        TextField("https://app.coolify.io", text: $coolifyUrl)
                            .textFieldStyle()
                    }
                    field(icon: "key.fill", tint: Palette.solar,
                          label: "apiToken") {
                        SecureField("Bearer Token", text: $coolifyToken)
                            .textFieldStyle()
                    }
                }

                section(title: "cloudflareAccess", tint: Palette.solar,
                        footer: "ifYouUseCloudflareAccess") {
                    field(icon: "person.badge.shield.checkmark.fill", tint: Palette.solar,
                          label: "cfClientId") {
                        TextField("CF-Access-Client-Id", text: $cfClientId)
                            .textFieldStyle()
                    }
                    field(icon: "key.fill", tint: Palette.solar,
                          label: "cfClientSecret") {
                        SecureField("CF-Access-Client-Secret", text: $cfClientSecret)
                            .textFieldStyle()
                    }
                }

                section(title: "cloudStorage", tint: Palette.plasma) {
                    field(icon: "square.stack.fill", tint: Palette.plasma,
                          label: "apiToken") {
                        SecureField("Token TorBox", text: $torboxToken)
                            .textFieldStyle()
                    }
                }

                about
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                PulseDot(tint: Palette.solar)
                Text("CONFIG")
                    .font(DSFont.caption)
                    .tracking(1.4)
                    .foregroundStyle(Palette.solar)
            }
            Text(String(localized: "settings"))
                .font(DSFont.title)
                .foregroundStyle(.white)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(title: LocalizedStringKey,
                                        tint: Color,
                                        footer: LocalizedStringKey? = nil,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(DSFont.section)
                .tracking(1.0)
                .foregroundStyle(Ink.dim)
                .textCase(.uppercase)
                .padding(.leading, 6)

            GlowCard(tint: tint) {
                VStack(spacing: 14) { content() }
            }

            if let footer {
                Text(footer)
                    .font(DSFont.monoSmall)
                    .foregroundStyle(Ink.dim)
                    .padding(.leading, 6)
            }
        }
    }

    @ViewBuilder
    private func field<Content: View>(icon: String,
                                      tint: Color,
                                      label: LocalizedStringKey,
                                      @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                    .shadow(color: tint.opacity(0.45), radius: 6, y: 2)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(DSFont.caption)
                    .tracking(0.6)
                    .foregroundStyle(Ink.dim)
                content()
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - About

    private var about: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("about")
                .font(DSFont.section)
                .tracking(1.0)
                .foregroundStyle(Ink.dim)
                .textCase(.uppercase)
                .padding(.leading, 6)

            GlowCard(tint: Palette.electric) {
                VStack(spacing: 14) {
                    HStack {
                        Text("version")
                            .font(DSFont.body)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("1.3.1-stable")
                            .font(DSFont.mono)
                            .foregroundStyle(Ink.dim)
                    }
                    Divider().background(Palette.hairline)
                    Link(destination: URL(string: "https://github.com/MathieuDubart/homelab")!) {
                        HStack {
                            Image(systemName: "terminal.fill")
                                .foregroundStyle(Palette.electric)
                            Text(String(localized: "sourceCode"))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Ink.dim)
                        }
                        .font(DSFont.body)
                    }
                }
            }
        }
    }
}

// MARK: - Text field styling

private extension View {
    func textFieldStyle() -> some View {
        self
            .font(DSFont.mono)
            .foregroundStyle(.white)
            .tint(Palette.electric)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

#Preview {
    ZStack {
        MeshBackground(tints: [Palette.solar, Palette.electric, Palette.plasma])
        SettingsView()
    }
    .preferredColorScheme(.dark)
}
