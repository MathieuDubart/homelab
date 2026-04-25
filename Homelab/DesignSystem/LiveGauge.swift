// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  LiveGauge.swift
//  Homelab
//

import SwiftUI

/// Big, animated circular gauge.
/// - Colour shifts through the mint → solar → ember spectrum based on value.
/// - Crosses the 80 % threshold with a warning haptic.
/// - Pulses softly while "live".
struct LiveGauge: View {
    let title: String
    let value: Double          // 0…100
    let detail: String?
    let systemImage: String
    var isLive: Bool = true

    @State private var previousBand: Int = 0

    private var normalized: Double { min(max(value / 100.0, 0), 1) }
    private var tint: Color { value.usageColor }

    var body: some View {
        ZStack {
            // Ambient glow behind the ring (static — no continuous reblur).
            Circle()
                .fill(tint.opacity(0.22))
                .blur(radius: 14)

            // Track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 14)

            // Progress ring with gradient + rounded cap
            Circle()
                .trim(from: 0, to: normalized)
                .stroke(
                    AngularGradient(
                        colors: [tint.opacity(0.6), tint, tint.opacity(0.9)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.6), radius: 10, y: 0)
                .animation(Motion.fluid, value: normalized)

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                    Text(title.uppercased())
                        .font(DSFont.caption)
                        .foregroundStyle(Ink.dim)
                        .tracking(1.2)
                }

                NumberRoll(value: value, suffix: "%")
                    .font(DSFont.display(38))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: value))

                if let detail {
                    Text(detail)
                        .font(DSFont.monoSmall)
                        .foregroundStyle(Ink.dim)
                }
            }
        }
        .frame(width: 160, height: 160)
        .onAppear {
            previousBand = band(for: value)
        }
        .onChange(of: value) { _, newValue in
            let b = band(for: newValue)
            if b != previousBand {
                if b >= 2 { Haptics.fire(.warning) }
                else      { Haptics.fire(.selection) }
                previousBand = b
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title) \(Int(value)) percent"))
    }

    private func band(for v: Double) -> Int {
        if v < 55  { return 0 }
        if v < 80  { return 1 }
        return 2
    }
}

/// A thin, live progress bar — used on torrent rows and inline stats.
struct NeonProgressBar: View {
    let progress: Double       // 0…1
    var tint: Color = Palette.electric
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.8), tint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .shadow(color: tint.opacity(0.6), radius: 6, y: 0)
                    .animation(Motion.fluid, value: progress)
            }
        }
        .frame(height: height)
    }
}

/// Animated numeric text — counts up to its target.
struct NumberRoll: View, Animatable {
    var value: Double
    var suffix: String = ""
    var decimals: Int = 0

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(formatted)
            .monospacedDigit()
    }

    private var formatted: String {
        String(format: "%.\(decimals)f\(suffix)", value)
    }
}

/// Small live "breathing" dot indicating data is streaming.
struct PulseDot: View {
    var tint: Color = Palette.mint
    @State private var breathing = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.35))
                .frame(width: 18, height: 18)
                .scaleEffect(breathing ? 1.4 : 0.8)
                .opacity(breathing ? 0 : 1)
                .animation(.easeOut(duration: 2.0).repeatForever(autoreverses: false), value: breathing)
            Circle()
                .fill(tint)
                .frame(width: 8, height: 8)
                .shadow(color: tint, radius: 4)
        }
        .onAppear { breathing = true }
        .onChange(of: scenePhase) { _, phase in
            breathing = (phase == .active)
        }
    }
}
