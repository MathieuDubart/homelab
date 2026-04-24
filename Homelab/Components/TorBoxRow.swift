//
//  TorBoxRow.swift
//  Homelab
//

import SwiftUI

struct TorBoxRow: View {
    let torrent: TorBoxItem

    private static let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useGB, .useMB]
        f.countStyle = .file
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            artwork

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(torrent.cleanName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !torrent.releaseYear.isEmpty {
                        Text(torrent.releaseYear)
                            .font(DSFont.monoSmall)
                            .foregroundStyle(Ink.dim)
                    }
                }

                HStack(spacing: 6) {
                    StatusPill(
                        text: torrent.status.rawValue,
                        tint: statusTint
                    )

                    if torrent.status == .downloading, let speed = torrent.downloadSpeed {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 9, weight: .bold))
                            Text("\(Self.byteCountFormatter.string(fromByteCount: speed))/s")
                                .font(DSFont.monoSmall)
                        }
                        .foregroundStyle(Palette.electric)
                    }

                    Spacer(minLength: 0)

                    Text("\(Int((torrent.progress ?? 0) * 100))%")
                        .font(DSFont.monoSmall)
                        .foregroundStyle(Ink.dim)
                }

                NeonProgressBar(
                    progress: torrent.progress ?? 0,
                    tint: statusTint,
                    height: 4
                )
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Sub views

    private var artwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [statusTint.opacity(0.45), statusTint.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 60)
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var iconName: String {
        switch torrent.status {
        case .completed, .cached: return "checkmark.circle.fill"
        case .downloading:        return "arrow.down.circle.fill"
        case .checking:           return "magnifyingglass.circle.fill"
        case .paused:             return "pause.circle.fill"
        case .error:              return "exclamationmark.triangle.fill"
        case .unknown:            return "questionmark.circle.fill"
        }
    }

    private var statusTint: Color {
        switch torrent.status {
        case .completed, .cached: return Palette.mint
        case .downloading, .checking: return Palette.electric
        case .paused: return Palette.solar
        case .error: return Palette.ember
        case .unknown: return Ink.dim.opacity(1)
        }
    }
}
