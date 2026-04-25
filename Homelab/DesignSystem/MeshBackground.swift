// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  MeshBackground.swift
//  Homelab
//

import SwiftUI

/// A living, slowly morphing mesh-gradient background.
/// Drives the overall DA: dark canvas with roaming coloured pools.
struct MeshBackground: View {
    var tints: [Color]
    var intensity: Double = 1.0

    @Environment(\.scenePhase) private var scenePhase

    init(tints: [Color] = [Palette.electric, Palette.plasma, Palette.solar]) {
        self.tints = tints
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 12.0, paused: scenePhase != .active)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                Palette.canvas.ignoresSafeArea()

                MeshGradient(
                    width: 3,
                    height: 3,
                    points: meshPoints(t: t),
                    colors: meshColors()
                )
                .opacity(0.78 * intensity)
                .blur(radius: 18)

                // Faint top highlight so the nav bar reads well
                LinearGradient(
                    colors: [Color.white.opacity(0.06), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
            .ignoresSafeArea()
        }
    }

    private func meshPoints(t: TimeInterval) -> [SIMD2<Float>] {
        func osc(_ phase: Double, _ amp: Double) -> Float {
            // Two-harmonic sum for a less robotic, more organic drift.
            Float((sin(t * 0.75 + phase) * 0.7 + sin(t * 0.31 + phase * 1.7) * 0.3) * amp)
        }
        return [
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5 + osc(0.1, 0.18), 0.0),
            SIMD2<Float>(1.0, 0.0),
            SIMD2<Float>(0.0, 0.5 + osc(1.2, 0.20)),
            SIMD2<Float>(0.5 + osc(2.3, 0.24), 0.5 + osc(3.1, 0.24)),
            SIMD2<Float>(1.0, 0.5 + osc(4.2, 0.20)),
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5 + osc(5.1, 0.18), 1.0),
            SIMD2<Float>(1.0, 1.0)
        ]
    }

    private func meshColors() -> [Color] {
        // 9 nodes, cycle through the provided tints for a painterly feel
        let base: [Color] = [
            Palette.canvas, tints[0].opacity(0.70), Palette.canvas,
            tints[1].opacity(0.55), tints[0].opacity(0.85), tints[2].opacity(0.55),
            Palette.canvas, tints[1].opacity(0.70), Palette.canvas
        ]
        return base
    }
}

// MARK: - Aurora overlay powered by the Metal shader

struct AuroraOverlay: View {
    var tintA: Color = Palette.electric
    var tintB: Color = Palette.plasma
    var amount: Double = 1.0

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                Rectangle()
                    .fill(.clear)
                    .background(
                        Rectangle()
                            .fill(Color.white)
                            .layerEffect(
                                ShaderLibrary.aurora(
                                    .float(Float(t)),
                                    .float2(Float(geo.size.width), Float(geo.size.height)),
                                    .color(tintA),
                                    .color(tintB)
                                ),
                                maxSampleOffset: .zero
                            )
                    )
                    .opacity(amount)
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            }
        }
    }
}
