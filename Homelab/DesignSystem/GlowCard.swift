// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  GlowCard.swift
//  Homelab
//

import SwiftUI

/// A glassy card with a subtle gradient stroke and soft shadow.
/// Wrap content in this to get the app's signature surface.
struct GlowCard<Content: View>: View {
    var tint: Color = Palette.electric
    var intensity: Double = 1.0
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                tint.opacity(0.55 * intensity),
                                Color.white.opacity(0.08),
                                tint.opacity(0.10 * intensity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 18, y: 10)
    }
}

/// A pill used for status badges.
struct StatusPill: View {
    let text: String
    var tint: Color

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(0.8)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(tint)
            .background(
                Capsule().fill(tint.opacity(0.15))
            )
            .overlay(
                Capsule().strokeBorder(tint.opacity(0.35), lineWidth: 0.8)
            )
    }
}

/// Pressed-state modifier with spring + soft haptic.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(Motion.snappy, value: configuration.isPressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.7),
                             trigger: configuration.isPressed) { old, new in
                new == true
            }
    }
}

extension View {
    func pressable() -> some View { buttonStyle(PressableStyle()) }
}
