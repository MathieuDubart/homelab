// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  MainTabView.swift
//  Homelab
//

import SwiftUI

struct MainTabView: View {
    @State private var selection: RootTab = .dashboard

    var body: some View {
        ZStack {
            MeshBackground(tints: selection.meshTints)
                .animation(.easeInOut(duration: 0.8), value: selection)

            Group {
                switch selection {
                case .dashboard: DashboardView()
                case .storage:   TorBoxView()
                case .settings:  SettingsView()
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                removal:   .opacity
            ))
            .id(selection)

            VStack {
                Spacer()
                FloatingTabBar(selection: $selection)
                    .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        .tint(selection.tint)
    }
}

private extension RootTab {
    var meshTints: [Color] {
        switch self {
        case .dashboard: return [Palette.electric, Palette.mint,   Palette.plasma]
        case .storage:   return [Palette.plasma,   Palette.electric, Palette.solar]
        case .settings:  return [Palette.solar,    Palette.plasma,   Palette.electric]
        }
    }
}

#Preview {
    MainTabView()
}
