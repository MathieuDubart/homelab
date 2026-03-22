//
//  CoolifyService.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//


import Foundation

import Foundation

class CoolifyService {
    private let baseURL: URL
    private let token: String
    
    init(host: String, token: String) {
        self.baseURL = URL(string: host)!
        self.token = token
    }
    
    enum Action: String {
        case start, stop, restart
    }
    
    func execute(action: Action, for containerName: String) async throws {
        let uuid = try await fetchServiceUuid(for: containerName)
        let url = baseURL.appendingPathComponent("/api/v1/services/\(uuid)/\(action.rawValue)")
        
        var request = URLRequest(url: url)
        
        let shared = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")
        if let id = shared?.string(forKey: "cf_client_id"),
            let secret = shared?.string(forKey: "cf_client_secret"),
           !id.isEmpty {
            request.setValue(id, forHTTPHeaderField: "CF-Access-Client-Id")
            request.setValue(secret, forHTTPHeaderField: "CF-Access-Client-Secret")
        }
        
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
    }
    
    private func fetchServiceUuid(for containerName: String) async throws -> String {
        let url = baseURL.appendingPathComponent("/api/v1/services")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let services = try JSONDecoder().decode([CoolifyServiceResource].self, from: data)
        
        let match = services.first { service in
            let lowContainer = containerName.lowercased()
            let lowName = service.name.lowercased()
            let lowUuid = service.uuid.lowercased()
            
            return lowContainer.contains(lowName) || lowContainer.contains(lowUuid)
        }
        
        guard let uuid = match?.uuid else {
            return containerName
        }
        
        return uuid
    }
}
