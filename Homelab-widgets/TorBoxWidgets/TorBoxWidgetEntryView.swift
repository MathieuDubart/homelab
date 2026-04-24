//
//  TorBoxWidgetEntryView.swift
//  Homelab-widgets
//

import SwiftUI
import WidgetKit
import AppIntents

struct TorBoxWidgetEntryView: View {
    var entry: TorBoxProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            if entry.torrents.isEmpty {
                emptyState
            } else {
                switch family {
                case .systemSmall:
                    if let torrent = entry.torrents.first {
                        SmallTorBoxRow(torrent: torrent)
                    }
                case .systemMedium:
                    VStack(spacing: 5) {
                        ForEach(entry.torrents.prefix(3)) { torrent in
                            MediumTorBoxRow(torrent: torrent)
                        }
                    }
                default:
                    Text("Unsupported")
                        .font(WFont.caption)
                        .foregroundStyle(WInk.dim)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) {
            WidgetBackdrop(tint: WPalette.plasma)
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(
                    LinearGradient(
                        colors: [WPalette.plasma, WPalette.electric],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: WPalette.plasma.opacity(0.55), radius: 4)

            Text("TorBox".uppercased())
                .font(WFont.title)
                .tracking(0.6)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, WInk.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Spacer()

            if !entry.torrents.isEmpty {
                WStatusPill(text: "\(entry.torrents.count)", tint: WPalette.plasma)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Spacer()
            ZStack {
                Circle()
                    .fill(WPalette.plasma.opacity(0.20))
                    .frame(width: 42, height: 42)
                    .blur(radius: 6)
                Image(systemName: "tray")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(WPalette.plasma.opacity(0.85))
            }
            Text("No active downloads")
                .font(WFont.caption)
                .foregroundStyle(WInk.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
