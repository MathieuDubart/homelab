// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  FloatingTabBar.swift
//  Homelab
//

import SwiftUI

struct FloatingTabBar: View {
    @Binding var selection: RootTab
    @Namespace private var blob

    var body: some View {
        HStack(spacing: 4) {
            ForEach(RootTab.allCases) { tab in
                Button {
                    Haptics.fire(.tabSwitch)
                    withAnimation(Motion.snappy) { selection = tab }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .bold))
                            .symbolEffect(.bounce, value: selection == tab)
                        if selection == tab {
                            Text(tab.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity
                                ))
                        }
                    }
                    .foregroundStyle(selection == tab ? .white : Ink.dim)
                    .padding(.horizontal, selection == tab ? 14 : 12)
                    .padding(.vertical, 10)
                    .background {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [tab.tint.opacity(0.95), tab.tint.opacity(0.55)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: tab.tint.opacity(0.6), radius: 10, y: 4)
                                .matchedGeometryEffect(id: "blob", in: blob)
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 20, y: 12)
        .padding(.horizontal, 24)
    }
}

enum RootTab: Int, CaseIterable, Identifiable {
    case dashboard, storage, settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard: return String(localized: "dashboard")
        case .storage:   return String(localized: "storage")
        case .settings:  return String(localized: "settings")
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .storage:   return "externaldrive.fill.badge.icloud"
        case .settings:  return "slider.horizontal.3"
        }
    }

    var tint: Color {
        switch self {
        case .dashboard: return Palette.electric
        case .storage:   return Palette.plasma
        case .settings:  return Palette.solar
        }
    }
}
