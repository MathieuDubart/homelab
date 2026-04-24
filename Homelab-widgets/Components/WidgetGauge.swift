//
//  WidgetGauge.swift
//  Homelab-widgets
//

import SwiftUI

/// Compact CPU / RAM gauge used on the system widget.
/// Colour tracks the mint → solar → ember spectrum so "hot" stats pop red
/// against the canvas without needing extra chrome.
struct WidgetGauge: View {
    let label: String
    let value: Double          // 0…100
    let icon: String

    private var tint: Color { value.wUsageColor }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(tint)
                Text(label.uppercased())
                    .font(WFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(WInk.dim)
                Spacer(minLength: 4)
                Text("\(Int(value))%")
                    .font(WFont.value)
                    .monospacedDigit()
                    .foregroundStyle(tint)
                    .shadow(color: tint.opacity(0.55), radius: 3)
            }

            WNeonBar(progress: value / 100, tint: tint, height: 6)
        }
    }
}
