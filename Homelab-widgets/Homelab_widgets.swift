// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  Homelab_widgets.swift
//  Homelab-widgets
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cpu: 38, ram: 54, topContainers: [
            WidgetContainer(name: "plex", memoryUsage: 842, memoryLimit: 0),
            WidgetContainer(name: "nextcloud", memoryUsage: 412, memoryLimit: 0),
            WidgetContainer(name: "vaultwarden", memoryUsage: 86, memoryLimit: 0)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")
        let url = sharedDefaults?.string(forKey: "glances_url") ?? ""

        Task {
            let stats = await fetchWidgetData(url: url)
            let containers = await fetchTopContainers(url: url)
            let entry = SimpleEntry(date: Date(), cpu: stats.cpu, ram: stats.mem, topContainers: containers)

            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct WidgetContainer: Identifiable {
    let id = UUID()
    let name: String
    let memoryUsage: Double
    let memoryLimit: Double

    var usagePercentage: Double {
        (memoryUsage / memoryLimit) * 100
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cpu: Double
    let ram: Double
    var topContainers: [WidgetContainer] = []
}

struct Homelab_widgetsEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    private var headerTint: Color {
        max(entry.cpu, entry.ram).wUsageColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            VStack(spacing: 8) {
                WidgetGauge(label: "CPU", value: entry.cpu, icon: "cpu.fill")
                WidgetGauge(label: "RAM", value: entry.ram, icon: "memorychip.fill")
            }

            if family == .systemMedium {
                Divider()
                    .overlay(WPalette.hairline)
                    .padding(.vertical, 2)

                VStack(alignment: .leading, spacing: 6) {
                    WSectionHeader(title: "Top RAM", icon: "shippingbox.fill", tint: WPalette.plasma)

                    VStack(spacing: 3) {
                        ForEach(entry.topContainers.prefix(1)) { container in
                            ContainerRow(container: container)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            WPulseDot(tint: headerTint)
            Text(family == .systemSmall ? "Lab" : "Homelab")
                .textCase(.uppercase)
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
            WStatusPill(text: pillText, tint: headerTint)
        }
    }

    private var pillText: String {
        let peak = max(entry.cpu, entry.ram)
        switch peak {
        case ..<55:  return "calm"
        case ..<80:  return "busy"
        default:     return "hot"
        }
    }
}

struct Homelab_widgets: Widget {
    let kind: String = "Homelab_widgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Homelab_widgetsEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackdrop(tint: WPalette.electric)
                }
        }
        .configurationDisplayName("systemMonitorTitle")
        .description("checkStatsAtAGlance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QuickStats {
    let cpu: Double
    let mem: Double
}

func fetchWidgetData(url: String) async -> QuickStats {
    guard let finalURL = URL(string: "\(url)/api/4/quicklook") else {
        return QuickStats(cpu: 0, mem: 0)
    }

    var request = URLRequest(url: finalURL)
    request.httpMethod = "GET"

    let shared = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")
    if let clientId = shared?.string(forKey: "cf_client_id"),
       let clientSecret = shared?.string(forKey: "cf_client_secret"),
       !clientId.isEmpty {

        request.setValue(clientId, forHTTPHeaderField: "CF-Access-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "CF-Access-Client-Secret")
    }

    do {
        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let cpu = json["cpu"] as? Double ?? 0
            let mem = json["mem"] as? Double ?? 0
            return QuickStats(cpu: cpu, mem: mem)
        }
    } catch {
        print("🚨 Widget Quicklook Error: \(error)")
    }
    return QuickStats(cpu: 0, mem: 0)
}

private func fetchTopContainers(url: String) async -> [WidgetContainer] {
    guard let finalURL = URL(string: "\(url)/api/4/containers") else { return [] }

    var request = URLRequest(url: finalURL)
    request.httpMethod = "GET"

    let shared = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")
    if let clientId = shared?.string(forKey: "cf_client_id"),
       let clientSecret = shared?.string(forKey: "cf_client_secret"),
       !clientId.isEmpty {

        request.setValue(clientId, forHTTPHeaderField: "CF-Access-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "CF-Access-Client-Secret")
    }

    do {
        let (data, _) = try await URLSession.shared.data(for: request)

        let rawContainers = try JSONDecoder().decode([DockerContainer].self, from: data)

        let sorted = rawContainers.sorted { ($0.memoryUsage ?? 0) > ($1.memoryUsage ?? 0) }
        let top3 = sorted.prefix(3).map { container in
            WidgetContainer(
                name: container.name,
                memoryUsage: Double(container.memoryUsage ?? 0) / (1024 * 1024),
                memoryLimit: 0
            )
        }
        return Array(top3)
    } catch {
        print("🚨 Widget Containers Error: \(error)")
        return []
    }
}

#Preview(as: .systemSmall) {
    Homelab_widgets()
} timeline: {
    SimpleEntry(date: .now, cpu: 45, ram: 60)
    SimpleEntry(date: .now, cpu: 72, ram: 85)
}

#Preview(as: .systemMedium) {
    Homelab_widgets()
} timeline: {
    SimpleEntry(
        date: .now, cpu: 38, ram: 54,
        topContainers: [
            WidgetContainer(name: "plex", memoryUsage: 842, memoryLimit: 0),
            WidgetContainer(name: "nextcloud", memoryUsage: 412, memoryLimit: 0),
            WidgetContainer(name: "vaultwarden", memoryUsage: 86, memoryLimit: 0)
        ]
    )
}
