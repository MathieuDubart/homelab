// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  OnboardingView.swift
//  Homelab

import SwiftUI

// MARK: - Per-page theme config

private let meshTintsList: [[Color]] = [
    [Palette.electric, Palette.mint,    Palette.plasma],   // welcome
    [Palette.electric, Palette.mint,    Palette.electric], // glances
    [Palette.solar,    Palette.plasma,  Palette.electric], // coolify
    [Palette.plasma,   Palette.electric, Palette.solar],   // torbox
    [Palette.mint,     Palette.electric, Palette.plasma],  // ready
]

private let pageTints: [Color] = [
    Palette.electric, Palette.electric, Palette.solar, Palette.plasma, Palette.mint,
]

private let pageCount = 5

// MARK: - Main view

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            MeshBackground(tints: meshTintsList[currentPage])
                .animation(.easeInOut(duration: 0.8), value: currentPage)

            VStack(spacing: 0) {
                skipButton.padding(.top, 8)

                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    GlancesPage().tag(1)
                    CoolifyPage().tag(2)
                    TorBoxPage().tag(3)
                    ReadyPage().tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomControls.padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Controls

    private var skipButton: some View {
        HStack {
            Spacer()
            if currentPage < pageCount - 1 {
                Button("Skip") {
                    Haptics.fire(.tabSwitch)
                    withAnimation(Motion.fluid) { hasSeenOnboarding = true }
                }
                .font(DSFont.body)
                .foregroundStyle(Ink.dim)
                .padding(.horizontal, 28)
                .transition(.opacity)
            } else {
                Color.clear.frame(height: 22)
            }
        }
        .animation(Motion.fluid, value: currentPage)
    }

    private var bottomControls: some View {
        VStack(spacing: 28) {
            pageIndicator
            actionButton
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage
                          ? pageTints[currentPage]
                          : Color.white.opacity(0.22))
                    .frame(width: index == currentPage ? 26 : 8, height: 8)
                    .animation(Motion.snappy, value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        let isLast = currentPage == pageCount - 1
        let tint = pageTints[currentPage]

        return Button {
            Haptics.fire(.tabSwitch)
            if isLast {
                withAnimation(Motion.fluid) { hasSeenOnboarding = true }
            } else {
                withAnimation(Motion.fluid) { currentPage += 1 }
            }
        } label: {
            HStack(spacing: 10) {
                Text(isLast ? String(localized: "Get Started") : String(localized: "Continue"))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Image(systemName: isLast ? "checkmark" : "arrow.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(Palette.canvas)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .fill(tint)
                    .shadow(color: tint.opacity(0.55), radius: 18, y: 8)
            )
            .animation(Motion.fluid, value: currentPage)
        }
        .padding(.horizontal, 32)
        .pressable()
    }
}

// MARK: - Individual pages

private struct WelcomePage: View {
    var body: some View {
        SimplePage(
            icon: "house.fill",
            tint: Palette.electric,
            headline: "Homelab",
            subhead: "Your homelab, beautifully monitored from your pocket."
        )
    }
}

private struct GlancesPage: View {
    @AppStorage("glances_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var glancesUrl: String = "https://"

    var body: some View {
        FormPage(icon: "gauge.with.dots.needle.67percent",
                 tint: Palette.electric,
                 headline: "Server Metrics",
                 subhead: "Connect your Glances instance to monitor your server live.") {
            OnboardingField(icon: "server.rack",
                            tint: Palette.electric,
                            label: "Glances API URL",
                            placeholder: "https://stats.yourdomain.com",
                            isSecure: false,
                            text: $glancesUrl)
        }
    }
}

private struct CoolifyPage: View {
    @AppStorage("coolify_url",       store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var coolifyUrl: String = "https://"
    @AppStorage("coolify_token",     store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var coolifyToken: String = ""
    @AppStorage("cf_client_id",      store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var cfClientId: String = ""
    @AppStorage("cf_client_secret",  store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var cfClientSecret: String = ""

    var body: some View {
        FormPage(icon: "shippingbox.fill",
                 tint: Palette.solar,
                 headline: "App Deployment",
                 subhead: "Monitor every app and service running on your Coolify instance.") {
            OnboardingField(icon: "shippingbox.fill",
                            tint: Palette.solar,
                            label: "Coolify URL",
                            placeholder: "https://app.coolify.io",
                            isSecure: false,
                            text: $coolifyUrl)
            Divider().background(Palette.hairline)
            OnboardingField(icon: "key.fill",
                            tint: Palette.solar,
                            label: "API Token",
                            placeholder: "Bearer Token",
                            isSecure: true,
                            text: $coolifyToken)
            Divider().background(Palette.hairline)

            HStack(spacing: 8) {
                Text("CLOUDFLARE ACCESS")
                    .font(DSFont.caption)
                    .tracking(1.0)
                    .foregroundStyle(Ink.dim)
                StatusPill(text: "Optional", tint: Palette.solar)
            }

            OnboardingField(icon: "person.badge.shield.checkmark.fill",
                            tint: Palette.solar,
                            label: "CF Client ID",
                            placeholder: "CF-Access-Client-Id",
                            isSecure: false,
                            text: $cfClientId)
            Divider().background(Palette.hairline)
            OnboardingField(icon: "key.fill",
                            tint: Palette.solar,
                            label: "CF Client Secret",
                            placeholder: "CF-Access-Client-Secret",
                            isSecure: true,
                            text: $cfClientSecret)
        }
    }
}

private struct TorBoxPage: View {
    @AppStorage("torbox_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var torboxToken: String = ""

    var body: some View {
        FormPage(icon: "externaldrive.fill.badge.icloud",
                 tint: Palette.plasma,
                 headline: "Cloud Storage",
                 subhead: "Track TorBox downloads and storage usage in real-time.") {
            OnboardingField(icon: "square.stack.fill",
                            tint: Palette.plasma,
                            label: "TorBox API Token",
                            placeholder: "Token TorBox",
                            isSecure: true,
                            text: $torboxToken)
        }
    }
}

private struct ReadyPage: View {
    var body: some View {
        SimplePage(
            icon: "checkmark.circle.fill",
            tint: Palette.mint,
            headline: "You're all set",
            subhead: "Jump in — you can always adjust your configuration in Settings."
        )
    }
}

// MARK: - Layout shells

private struct SimplePage: View {
    let icon: String
    let tint: Color
    let headline: String
    let subhead: String

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 36) {
            IconBadge(icon: icon, tint: tint)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
            TextBlock(headline: headline, subhead: subhead)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)
        }
        .padding(.horizontal, 24)
        .onAppear  { withAnimation(Motion.bouncy.delay(0.05)) { appeared = true } }
        .onDisappear { appeared = false }
    }
}

private struct FormPage<F: View>: View {
    let icon: String
    let tint: Color
    let headline: String
    let subhead: String
    let fields: F

    @State private var appeared = false

    init(icon: String, tint: Color, headline: String, subhead: String,
         @ViewBuilder fields: () -> F) {
        self.icon = icon
        self.tint = tint
        self.headline = headline
        self.subhead = subhead
        self.fields = fields()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                IconBadge(icon: icon, tint: tint, size: 82)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)

                TextBlock(headline: headline, subhead: subhead)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)

                GlowCard(tint: tint) {
                    VStack(spacing: 14) { fields }
                }
                .offset(y: appeared ? 0 : 24)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .onAppear  { withAnimation(Motion.bouncy.delay(0.05)) { appeared = true } }
        .onDisappear { appeared = false }
    }
}

// MARK: - Atoms

private struct IconBadge: View {
    let icon: String
    let tint: Color
    var size: CGFloat = 108

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [tint.opacity(0.28), .clear],
                    center: .center,
                    startRadius: size * 0.28,
                    endRadius: size * 0.84
                ))
                .frame(width: size * 1.67, height: size * 1.67)

            RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                .fill(LinearGradient(
                    colors: [tint, tint.opacity(0.60)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: tint.opacity(0.65), radius: 28, y: 14)

            Image(systemName: icon)
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

private struct TextBlock: View {
    let headline: String
    let subhead: String

    var body: some View {
        VStack(spacing: 14) {
            Text(headline)
                .font(DSFont.hero)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(subhead)
                .font(DSFont.body)
                .foregroundStyle(Ink.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 8)
        }
    }
}

private struct OnboardingField: View {
    let icon: String
    let tint: Color
    let label: String
    let placeholder: String
    let isSecure: Bool
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(
                        colors: [tint, tint.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .fieldStyling()
                } else {
                    TextField(placeholder, text: $text)
                        .fieldStyling()
                }
            }
            Spacer(minLength: 0)
        }
    }
}

private extension View {
    func fieldStyling() -> some View {
        self
            .font(DSFont.mono)
            .foregroundStyle(.white)
            .tint(Palette.electric)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
