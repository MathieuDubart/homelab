// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxItem.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import Foundation
struct TorBoxItem: Codable, Identifiable {
    let id: Int
    let name: String
    let progress: Double?
    let status: TorBoxStatus
    let size: Int64
    let downloadSpeed: Int64?
    let uploadSpeed: Int64?
    let seeds: Int?
    let peers: Int?
    let eta: Int?
    let ratio: Double?
    let downloadFinished: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, progress, size, seeds, peers, eta, ratio
        case status = "download_state"
        case downloadSpeed = "download_speed"
        case uploadSpeed = "upload_speed"
        case downloadFinished = "download_finished"
    }
    
    var fileIcon: String {
        let name = self.name.lowercased()
        if name.contains(".mkv") || name.contains(".mp4") { return "movieclapper.fill" }
        if name.contains(".zip") || name.contains(".rar") { return "doc.zipper" }
        if name.contains(".iso") { return "opticaldisc" }
        return "doc.fill"
    }
    
    var cleanName: String {
        let pattern = #"(^.*?)(?=\s?[\s.\[\(](\d{4})[\s.\]\)])"#
        if let range = self.name.range(of: pattern, options: .regularExpression) {
            return String(self.name[range]).replacingOccurrences(of: ".", with: " ")
        }
        return self.name.replacingOccurrences(of: ".", with: " ")
    }
    
    var releaseYear: String {
        let pattern = #"\d{4}"#
        if let range = self.name.range(of: pattern, options: .regularExpression) {
            return String(self.name[range])
        }
        return ""
    }
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(self.size), countStyle: .file)
    }
}


