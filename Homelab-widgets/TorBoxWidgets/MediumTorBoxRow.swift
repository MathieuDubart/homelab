// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  MediumTorBoxRow.swift
//  Homelab-widgets
//

import SwiftUI
import AppIntents

struct MediumTorBoxRow: View {
    let torrent: TorBoxItem

    private var tint: Color { torrent.status.wTint }
    private var progress: Double { torrent.progress ?? 0 }

    private static let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useGB, .useMB]
        f.countStyle = .file
        return f
    }()

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: torrent.fileIcon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 18, height: 18)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tint.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(tint.opacity(0.35), lineWidth: 0.6)
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(torrent.cleanName.isEmpty ? torrent.name : torrent.cleanName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(WInk.primary)
                        .lineLimit(1)
                    Spacer(minLength: 2)
                    Text("\(Int(progress * 100))%")
                        .font(WFont.monoSmall)
                        .monospacedDigit()
                        .foregroundStyle(tint)
                }

                WNeonBar(progress: progress, tint: tint, height: 4)

                HStack(spacing: 4) {
                    if torrent.status == .downloading, let speed = torrent.downloadSpeed, speed > 0 {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(tint)
                        Text("\(Self.byteCountFormatter.string(fromByteCount: speed))/s")
                            .font(WFont.monoSmall)
                            .foregroundStyle(WInk.secondary)
                    } else {
                        WStatusPill(text: torrent.status.wLabel, tint: tint)
                    }
                    Spacer(minLength: 2)
                    Text(Self.byteCountFormatter.string(fromByteCount: torrent.size))
                        .font(WFont.monoSmall)
                        .foregroundStyle(WInk.dim)
                }
            }

            Button(intent: DeleteTorrentIntent(id: torrent.id, name: torrent.name)) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(WPalette.ember)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(WPalette.ember.opacity(0.18))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(WPalette.ember.opacity(0.40), lineWidth: 0.6)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(tint.opacity(0.22), lineWidth: 0.6)
        )
    }
}
