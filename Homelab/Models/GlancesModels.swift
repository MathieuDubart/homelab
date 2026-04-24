// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  CPUStats.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//


import Foundation

/* nonisolated used for strict concurrency */
nonisolated struct CPUStats: Codable, Sendable {
    let total: Double
}

nonisolated struct RAMStats: Codable {
    let percent: Double
    let used: Int64
    let total: Int64
}

nonisolated struct DockerContainer: Codable, Identifiable, Sendable, Equatable {
    var id: String { name }
    let name: String
    let status: String
    
    let cpu: Double?
    let memoryUsage: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, status
        case cpu = "cpu_percent"
        case memoryUsage = "memory_usage"
    }
}

nonisolated struct ServerSnapshot: Sendable {
    let cpu: CPUStats
    let ram: RAMStats
    let containers: [DockerContainer]
}
