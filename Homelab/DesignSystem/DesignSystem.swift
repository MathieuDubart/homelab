//
//  DesignSystem.swift
//  Homelab
//

import SwiftUI

// MARK: - Palette

enum Palette {
    // Base surfaces — deep neutral with a subtle blueish cast
    static let canvas       = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let canvasRaised = Color(red: 0.07, green: 0.08, blue: 0.12)
    static let hairline     = Color.white.opacity(0.08)

    // Brand accents — electric, saturated, distinct per domain
    static let electric = Color(red: 0.34, green: 0.76, blue: 1.00)   // cyan/blue — system / dashboard
    static let plasma   = Color(red: 0.86, green: 0.35, blue: 1.00)   // magenta — TorBox / storage
    static let solar    = Color(red: 1.00, green: 0.72, blue: 0.20)   // amber — coolify / warning
    static let mint     = Color(red: 0.38, green: 0.95, blue: 0.67)   // mint — success / healthy
    static let ember    = Color(red: 1.00, green: 0.36, blue: 0.42)   // red — danger

    // Gradient stops used for hero mesh / gauges
    static let gradientCool:  [Color] = [electric, plasma]
    static let gradientWarm:  [Color] = [solar,    ember]
    static let gradientLife:  [Color] = [mint,     electric]
}

// MARK: - Semantic colors (swap to SwiftUI system where relevant)

enum Ink {
    static let primary   = Color.primary
    static let secondary = Color.secondary
    static let dim       = Color.white.opacity(0.45)
}

// MARK: - Typography

enum DSFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static let hero       = Font.system(size: 48, weight: .heavy,   design: .rounded)
    static let title      = Font.system(size: 28, weight: .bold,    design: .rounded)
    static let section    = Font.system(size: 13, weight: .semibold,design: .rounded)
    static let body       = Font.system(size: 15, weight: .regular, design: .rounded)
    static let mono       = Font.system(size: 13, weight: .medium,  design: .monospaced)
    static let monoSmall  = Font.system(size: 11, weight: .semibold,design: .monospaced)
    static let caption    = Font.system(size: 11, weight: .semibold,design: .rounded)
}

// MARK: - Motion

enum Motion {
    /// Snappy spring for micro-interactions (taps, toggles)
    static let snappy: Animation = .spring(response: 0.32, dampingFraction: 0.72)
    /// Gentle spring for value transitions (gauges, counters)
    static let fluid:  Animation = .spring(response: 0.55, dampingFraction: 0.80)
    /// Bouncy spring reserved for hero events
    static let bouncy: Animation = .spring(response: 0.45, dampingFraction: 0.60)
    /// Slow ambient animation for backgrounds
    static let ambient: Animation = .easeInOut(duration: 8).repeatForever(autoreverses: true)
}

// MARK: - Radii

enum Radius {
    static let s:  CGFloat = 10
    static let m:  CGFloat = 18
    static let l:  CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Status color resolver

extension Double {
    /// Maps a 0…100 usage value onto the mint → solar → ember spectrum.
    var usageColor: Color {
        switch self {
        case ..<55:  return Palette.mint
        case ..<80:  return Palette.solar
        default:     return Palette.ember
        }
    }
}
