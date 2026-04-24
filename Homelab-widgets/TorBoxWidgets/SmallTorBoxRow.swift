//
//  SmallTorBoxRow.swift
//  Homelab-widgets
//

import SwiftUI
import AppIntents

struct SmallTorBoxRow: View {
    let torrent: TorBoxItem

    private var tint: Color { torrent.status.wTint }
    private var progress: Double { torrent.progress ?? 0 }

    private static let sizeFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useGB, .useMB]
        f.countStyle = .file
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    WNeonRing(
                        progress: progress,
                        label: "\(Int(progress * 100))%",
                        tint: tint,
                        lineWidth: 4
                    )
                    .frame(width: 42, height: 42)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: torrent.fileIcon)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(tint)
                        WStatusPill(text: torrent.status.wLabel, tint: tint)
                    }

                    Text(torrent.cleanName.isEmpty ? torrent.name : torrent.cleanName)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(WInk.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer(minLength: 6)

            HStack(spacing: 4) {
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(WInk.dim)
                Text(Self.sizeFormatter.string(fromByteCount: torrent.size))
                    .font(WFont.monoSmall)
                    .foregroundStyle(WInk.secondary)
            }

            Button(intent: DeleteTorrentIntent(id: torrent.id, name: torrent.name)) {
                HStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 10, weight: .heavy))
                    Text("Delete")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .foregroundStyle(WPalette.ember)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(WPalette.ember.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(WPalette.ember.opacity(0.40), lineWidth: 0.8)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }
}
