// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  DashboardView.swift
//  Homelab
//

import SwiftUI

struct DashboardView: View {
    @AppStorage("glances_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var glancesUrl: String = ""

    @State private var viewModel: DashboardViewModel?
    @State private var lastRefresh: Date = .now

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                    .padding(.top, 12)

                if glancesUrl.isEmpty || glancesUrl == "https://" {
                    setupRequiredView
                        .padding(.top, 40)
                } else if let vm = viewModel {
                    heroStats(vm: vm)
                    servicesSection(vm: vm)
                } else {
                    ProgressView(LocalizedStringResource.initialisation)
                        .tint(Palette.electric)
                        .frame(maxWidth: .infinity, minHeight: 200)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120) // space for the floating tab bar
        }
        .scrollIndicators(.hidden)
        .refreshable {
            Haptics.fire(.refresh)
            await viewModel?.fetchData()
            lastRefresh = .now
            Haptics.fire(.success)
        }
        .onAppear { refreshViewModel() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    PulseDot(tint: hasData ? Palette.mint : Palette.solar)
                    Text(hasData ? "LIVE" : "IDLE")
                        .font(DSFont.caption)
                        .tracking(1.4)
                        .foregroundStyle(hasData ? Palette.mint : Palette.solar)
                }
                Text(String(localized: "systemMonitorTitle"))
                    .font(DSFont.title)
                    .foregroundStyle(.white)
                Text(lastRefresh.formatted(.relative(presentation: .named)))
                    .font(DSFont.monoSmall)
                    .foregroundStyle(Ink.dim)
            }
            Spacer()
        }
    }

    // MARK: - Hero stats

    private func heroStats(vm: DashboardViewModel) -> some View {
        GlowCard(tint: Palette.electric) {
            VStack(spacing: 20) {
                HStack(spacing: 24) {
                    LiveGauge(
                        title: "CPU",
                        value: vm.cpuUsage,
                        detail: nil,
                        systemImage: "cpu"
                    )
                    LiveGauge(
                        title: "RAM",
                        value: vm.ramUsage,
                        detail: vm.ramDetailString,
                        systemImage: "memorychip"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                Divider().background(Palette.hairline)

                metricsStrip(vm: vm)
            }
        }
    }

    @ViewBuilder
    private func metricsStrip(vm: DashboardViewModel) -> some View {
        HStack {
            metricTile(
                label: String(localized: "servicesTitle"),
                value: "\(vm.containers.count)",
                tint: Palette.plasma,
                icon: "shippingbox.fill"
            )
            Divider().background(Palette.hairline).frame(height: 32)
            metricTile(
                label: "Healthy",
                value: "\(healthyCount(vm: vm))",
                tint: Palette.mint,
                icon: "checkmark.seal.fill"
            )
            Divider().background(Palette.hairline).frame(height: 32)
            metricTile(
                label: "Alerts",
                value: "\(alertCount(vm: vm))",
                tint: alertCount(vm: vm) > 0 ? Palette.ember : Ink.dim,
                icon: "bell.fill"
            )
        }
    }

    private func metricTile(label: String, value: String, tint: Color, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(DSFont.display(20, weight: .bold))
                    .foregroundStyle(.white)
                Text(label.uppercased())
                    .font(DSFont.caption)
                    .tracking(0.8)
                    .foregroundStyle(Ink.dim)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Services

    private func servicesSection(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "servicesTitle").uppercased())
                    .font(DSFont.section)
                    .tracking(1.2)
                    .foregroundStyle(Ink.dim)
                Spacer()
                Text("\(vm.sortedContainers.count)")
                    .font(DSFont.monoSmall)
                    .foregroundStyle(Ink.dim)
            }
            .padding(.horizontal, 4)

            if vm.sortedContainers.isEmpty && !vm.isLoading {
                GlowCard(tint: Palette.plasma) {
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 28))
                            .foregroundStyle(Palette.plasma)
                        Text(String(localized: "noContainerAvailable"))
                            .font(DSFont.body)
                            .foregroundStyle(Ink.dim)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(vm.sortedContainers) { container in
                        ContainerRow(container: container)
                    }
                }
            }
        }
    }

    // MARK: - Empty state

    private var setupRequiredView: some View {
        GlowCard(tint: Palette.solar) {
            VStack(spacing: 14) {
                Image(systemName: "server.rack")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(colors: Palette.gradientCool,
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .padding(.top, 6)
                Text(String(localized: "checkStatsAtAGlance"))
                    .font(DSFont.title)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(String(localized: "enterGlancesUrl"))
                    .font(DSFont.body)
                    .foregroundStyle(Ink.dim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
        }
    }

    // MARK: - Helpers

    private var hasData: Bool {
        (viewModel?.cpuUsage ?? 0) > 0 || (viewModel?.ramUsage ?? 0) > 0
    }

    private func healthyCount(vm: DashboardViewModel) -> Int {
        vm.containers.filter {
            let s = $0.status.lowercased()
            return s.contains("healthy") || s.contains("up") || s == "running"
        }.count
    }

    private func alertCount(vm: DashboardViewModel) -> Int {
        var n = 0
        if vm.cpuUsage >= 80 { n += 1 }
        if vm.ramUsage >= 80 { n += 1 }
        n += vm.containers.filter {
            let s = $0.status.lowercased()
            return !(s.contains("healthy") || s.contains("up") || s == "running")
        }.count
        return n
    }

    private func refreshViewModel() {
        guard !glancesUrl.isEmpty, glancesUrl != "https://" else { return }
        if viewModel == nil {
            viewModel = DashboardViewModel(host: glancesUrl)
            viewModel?.startMonitoring()
        }
    }
}

#Preview {
    ZStack {
        MeshBackground()
        DashboardView()
    }
    .preferredColorScheme(.dark)
}
