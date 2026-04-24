//
//  WidgetDesign.swift
//  Homelab-widgets
//

import SwiftUI

// MARK: - Palette (mirrors main app's DesignSystem)

enum WPalette {
    static let canvas       = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let canvasRaised = Color(red: 0.07, green: 0.08, blue: 0.12)
    static let hairline     = Color.white.opacity(0.10)

    static let electric = Color(red: 0.34, green: 0.76, blue: 1.00)
    static let plasma   = Color(red: 0.86, green: 0.35, blue: 1.00)
    static let solar    = Color(red: 1.00, green: 0.72, blue: 0.20)
    static let mint     = Color(red: 0.38, green: 0.95, blue: 0.67)
    static let ember    = Color(red: 1.00, green: 0.36, blue: 0.42)
}

enum WInk {
    static let primary = Color.white
    static let secondary = Color.white.opacity(0.62)
    static let dim = Color.white.opacity(0.38)
}

extension Double {
    var wUsageColor: Color {
        switch self {
        case ..<55:  return WPalette.mint
        case ..<80:  return WPalette.solar
        default:     return WPalette.ember
        }
    }
}

extension TorBoxStatus {
    /// Widget-specific tint that matches the design system palette.
    var wTint: Color {
        switch self {
        case .completed, .cached:     return WPalette.mint
        case .downloading, .checking: return WPalette.electric
        case .paused:                 return WPalette.solar
        case .error:                  return WPalette.ember
        case .unknown:                return WPalette.plasma
        }
    }

    var wLabel: String {
        switch self {
        case .completed:   return "done"
        case .cached:      return "cached"
        case .downloading: return "dl"
        case .checking:    return "check"
        case .paused:      return "paused"
        case .error:       return "error"
        case .unknown:     return "—"
        }
    }
}

// MARK: - Typography

enum WFont {
    static let display: Font       = .system(size: 22, weight: .heavy,    design: .rounded)
    static let title: Font         = .system(size: 14, weight: .heavy,    design: .rounded)
    static let value: Font         = .system(size: 13, weight: .heavy,    design: .rounded)
    static let caption: Font       = .system(size: 9,  weight: .bold,     design: .rounded)
    static let mono: Font          = .system(size: 10, weight: .semibold, design: .monospaced)
    static let monoSmall: Font     = .system(size: 9,  weight: .bold,     design: .monospaced)
    static let row: Font           = .system(size: 11, weight: .semibold, design: .rounded)
}

// MARK: - Backdrop

/// A subtle radial / linear gradient backdrop tinted to the widget's domain.
/// Designed to work under `.containerBackground(for: .widget)`.
struct WidgetBackdrop: View {
    var tint: Color

    var body: some View {
        ZStack {
            WPalette.canvasRaised
            LinearGradient(
                colors: [
                    tint.opacity(0.22),
                    WPalette.canvasRaised.opacity(0),
                    tint.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [tint.opacity(0.28), .clear],
                center: .topTrailing,
                startRadius: 2,
                endRadius: 180
            )
            .blendMode(.plusLighter)
        }
    }
}

// MARK: - Neon bar (linear gauge)

/// Gradient-filled capsule with soft glow. Lightweight: no animation loops.
struct WNeonBar: View {
    let progress: Double   // 0…1
    var tint: Color = WPalette.electric
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                    )

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.75), tint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .shadow(color: tint.opacity(0.55), radius: 4, y: 0)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Neon ring (circular gauge)

/// Compact angular-gradient ring with a value label.
struct WNeonRing: View {
    let progress: Double   // 0…1
    let label: String      // center label (e.g. "45%")
    var tint: Color = WPalette.electric
    var lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.09), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    AngularGradient(
                        colors: [tint.opacity(0.5), tint, tint.opacity(0.9)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.55), radius: 4)

            Text(label)
                .font(WFont.monoSmall)
                .foregroundStyle(WInk.primary)
        }
    }
}

// MARK: - Status pill

struct WStatusPill: View {
    let text: String
    var tint: Color

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .tracking(0.6)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(tint)
            .background(Capsule().fill(tint.opacity(0.18)))
            .overlay(Capsule().strokeBorder(tint.opacity(0.35), lineWidth: 0.6))
    }
}

// MARK: - Section header

struct WSectionHeader: View {
    let title: String
    var icon: String
    var tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
            Text(title.uppercased())
                .font(WFont.caption)
                .tracking(0.8)
                .foregroundStyle(WInk.dim)
        }
    }
}

// MARK: - Pulse dot (static for widgets — just a glowing dot)

struct WPulseDot: View {
    var tint: Color = WPalette.mint

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.35))
                .frame(width: 10, height: 10)
                .blur(radius: 2)
            Circle()
                .fill(tint)
                .frame(width: 5, height: 5)
                .shadow(color: tint, radius: 3)
        }
        .frame(width: 10, height: 10)
    }
}
