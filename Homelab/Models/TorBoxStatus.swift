// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxStatus.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import Foundation
import SwiftUI

enum TorBoxStatus: String, Codable {
    case downloading = "downloading"
    case completed = "completed"
    case paused = "paused"
    case error = "error"
    case checking = "checking"
    case unknown = "unknown"
    case cached = "cached"
    
    // Handling potential new status
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let statusString = try container.decode(String.self)
        self = TorBoxStatus(rawValue: statusString) ?? .unknown
    }
    
    var color: Color {
        switch self {
        case .completed, .cached: return .green
        case .downloading, .checking: return .blue
        case .paused: return .orange
        case .error: return .red
        case .unknown: return .secondary
        }
    }
}
