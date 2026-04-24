// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxService.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import Foundation

class TorBoxService {
    private let token: String
    private let baseURL = "https://api.torbox.app/v1/api"
    
    init(token: String) {
        self.token = token
    }
    
    private func performRequest<T: Codable>(endpoint: String) async throws -> T {
        guard !token.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    func fetchTorrents() async throws -> [TorBoxItem] {
        let endpoint = "/torrents/mylist"
        
        let response: TorBoxResponse = try await performRequest(endpoint: endpoint)
        
        if response.success {
            return response.data
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func pauseTorrent(id: Int) async throws {
        try await performAction(endpoint: "/torrents/controltorrent", action: "pause", torrentId: id)
    }
    
    func resumeTorrent(id: Int) async throws {
        try await performAction(endpoint: "/torrents/controltorrent", action: "resume", torrentId: id)
    }
    
    func removeTorrent(id: Int) async throws {
        try await performAction(endpoint: "/torrents/controltorrent", action: "delete", torrentId: id)
    }
    
    private func performAction(endpoint: String, action: String, torrentId: Int) async throws {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "torrent_id": torrentId,
            "operation": action // 'pause', 'resume', or 'remove'
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorBody = String(data: data, encoding: .utf8) { print("❌ TorBox Action Error: \(errorBody)") }
            throw URLError(.badServerResponse)
        }
    }
    
}
