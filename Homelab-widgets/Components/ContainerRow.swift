// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  ContainerRow.swift
//  Homelab-widgets
//

import SwiftUI

struct ContainerRow: View {
    let container: WidgetContainer

    private var tint: Color {
        let mb = container.memoryUsage
        if mb > 1000 { return WPalette.ember }
        if mb > 500  { return WPalette.solar }
        return WPalette.mint
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 5, height: 5)
                .shadow(color: tint.opacity(0.7), radius: 2)

            Text(container.name)
                .font(WFont.row)
                .foregroundStyle(WInk.primary)
                .lineLimit(1)

            Spacer(minLength: 4)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(container.memoryUsage))")
                    .font(WFont.mono)
                    .monospacedDigit()
                    .foregroundStyle(tint)
                Text("MB")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(WInk.dim)
            }
        }
    }
}
