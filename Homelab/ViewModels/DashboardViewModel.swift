// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  DashboardViewModel.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//


import Foundation
import Observation
import WidgetKit

@Observable
class DashboardViewModel {
    //Data States
    var cpuUsage: Double = 0.0
    var ramUsage: Double = 0.0
    var usedRamBytes: Int64 = 0
    var totalRamBytes: Int64 = 0
    var containers: [DockerContainer] = []
    
    var ramDetailString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .memory
        
        let usedStr = formatter.string(fromByteCount: Int64(usedRamBytes))
        let totalStr = formatter.string(fromByteCount: Int64(totalRamBytes))
        
        return "\(usedStr) / \(totalStr)"
    }
    
    // UI States
    var isLoading = false
    var errorMessage: String?
    var sortedContainers: [DockerContainer] {
        return containers.sorted { ($0.memoryUsage ?? 0) > ($1.memoryUsage ?? 0) }
    }
    
    private let client: GlancesService
    private var refreshTimer: Timer?

    init(host: String) {
        self.client = GlancesService(host: host, apiVersion: "4")
    }

    /// Entry point for monitoring
    func startMonitoring() {
        stopMonitoring()
        
        Task { await fetchData() }
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            Task { [weak self] in
                await self?.fetchData()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @MainActor
    public func fetchData() async {
        guard !isLoading else { return }
        
        do {
            let snapshot = try await client.fetchFullSnapshot()
            
            // Data update
            self.cpuUsage = snapshot.cpu.total
            self.ramUsage = snapshot.ram.percent
            self.usedRamBytes = snapshot.ram.used
            self.totalRamBytes = snapshot.ram.total
            self.containers = snapshot.containers
            self.errorMessage = nil
        } catch {
            self.errorMessage = "\(LocalizedStringResource.connexionError): \(error.localizedDescription)"
        }
    }
    
    
    func checkAlerts(cpu: Double, ram: Double, containers: [DockerContainer]) {
        if cpu > 90 {
            NotificationManager.instance.sendAlert(
                title: "🚨 CPU: \(Int(cpu))%",
                body: "\(LocalizedStringResource.serverIsStruggling)"
            )
        }
        
        if ram > 90 {
            NotificationManager.instance.sendAlert(
                title: "🚨 RAM: \(Int(ram))%",
                body: "\(LocalizedStringResource.serverIsStruggling)"
            )
        }
        
        if cpu > 70 && cpu < 90 {
            NotificationManager.instance.sendAlert(
                title: "⚠️ CPU: \(Int(cpu))%",
                body: "\(LocalizedStringResource.highCpuUsage)"
            )
        }
        
        if ram > 70 && ram < 90 {
            NotificationManager.instance.sendAlert(
                title: "⚠️ RAM: \(Int(ram))%",
                body: "\(LocalizedStringResource.highMemoryUsage)"
            )
        }
        
        for container in containers {
            if container.status != "running" {
                NotificationManager.instance.sendAlert(
                    title: "🚨 Container Stopped",
                    body: "\(container.name) is \(container.status)."
                )
            }
        }
    }
    
}
