// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxProvider.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//

import WidgetKit

struct TorBoxProvider: TimelineProvider {
    func placeholder(in context: Context) -> TorBoxEntry {
        TorBoxEntry(date: Date(), torrents: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TorBoxEntry) -> ()) {
        completion(TorBoxEntry(date: Date(), torrents: []))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TorBoxEntry>) -> ()) {
        Task {
            let token = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")?.string(forKey: "torbox_token") ?? ""
            let service = TorBoxService(token: token)
            
            do {
                let allTorrents = try await service.fetchTorrents()
                let deletedIDs = DeletedTorrentsManager.instance.getDeletedIDs()
                let filtered = allTorrents.filter { !deletedIDs.contains($0.id) }
                
                let entry = TorBoxEntry(date: Date(), torrents: filtered)
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300))) // Refresh toutes les 5min
                completion(timeline)
            } catch {
                let entry = TorBoxEntry(date: Date(), torrents: [])
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
                completion(timeline)
            }
        }
    }
}
