//
//  ContainerRow.swift
//  Homelab
//

import SwiftUI

struct ContainerRow: View {
    let container: DockerContainer

    private let cpuCriticalThreshold: Double = 80
    private let ramCriticalThresholdBytes: Int = 1_024_000_000 // 1 GB

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            iconBadge

            VStack(alignment: .leading, spacing: 6) {
                Text(container.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)

                StatusPill(text: container.status, tint: isHealthy ? Palette.mint : Palette.solar)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                metric(
                    icon: "memorychip",
                    text: formattedMemory,
                    critical: isRamCritical,
                    tint: Palette.plasma
                )
                metric(
                    icon: "cpu",
                    text: "\(String(format: "%.1f", container.cpu ?? 0))%",
                    critical: isCpuCritical,
                    tint: Palette.electric
                )
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

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            (isHealthy ? Palette.mint : Palette.solar).opacity(0.35),
                            (isHealthy ? Palette.mint : Palette.solar).opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 38, height: 38)
            Image(systemName: isHealthy ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isHealthy ? Palette.mint : Palette.solar)
        }
    }

    private func metric(icon: String, text: String, critical: Bool, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(DSFont.monoSmall)
        }
        .foregroundStyle(critical ? Palette.ember : tint.opacity(0.9))
        .fontWeight(critical ? .bold : .regular)
    }

    // MARK: - Helpers

    private var formattedMemory: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(container.memoryUsage ?? 0))
    }

    private var isHealthy: Bool {
        let status = container.status.lowercased()
        return status.contains("healthy") || status.contains("up") || status == "running"
    }

    private var isCpuCritical: Bool { (container.cpu ?? 0) >= cpuCriticalThreshold }
    private var isRamCritical: Bool { (container.memoryUsage ?? 0) >= ramCriticalThresholdBytes }
}
