// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxViewModel.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import Foundation
import Combine
import SwiftUI
import WidgetKit

@MainActor
class TorBoxViewModel: ObservableObject {
    @Published var torrents: [TorBoxItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    @Published private var activeDownloadIDs: Set<Int> = []
    private var refreshTask: Task<Void, Never>? = nil
    
    let service: TorBoxService
    
    init(token: String) {
        self.service = TorBoxService(token: token)
    }
    
    func loadTorrents() async {
        refreshTask?.cancel()
        
        do {
            let freshTorrents = try await service.fetchTorrents()

            let deletedIDs = DeletedTorrentsManager.instance.getDeletedIDs()
            
            let filteredTorrents = freshTorrents.filter { torrent in
                !deletedIDs.contains(torrent.id)
            }
            
            for torrent in filteredTorrents {
                if activeDownloadIDs.contains(torrent.id) && torrent.status == .completed {
                    NotificationManager.instance.sendDownloadCompleteNotification(torrentName: torrent.name)
                    activeDownloadIDs.remove(torrent.id) // On le retire des "actifs"
                }
                
                if torrent.status == .downloading || torrent.status == .checking {
                    activeDownloadIDs.insert(torrent.id)
                }
            }
            
            withAnimation {
                self.torrents = filteredTorrents
            }
            
            let hasActiveDownloads = filteredTorrents.contains {
                $0.status == .downloading || $0.status == .checking || $0.status == .paused
            }
            
            if filteredTorrents.isEmpty || hasActiveDownloads {
                scheduleSmartRefresh()
            }
            
            let fetchedIDs = Set(freshTorrents.map { $0.id })
            DeletedTorrentsManager.instance.clean(keeping: fetchedIDs)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    private func scheduleSmartRefresh() {
        refreshTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            
            if !Task.isCancelled {
                print("🔄 TorBox Smart Refresh...")
                await loadTorrents()
            }
        }
    }
    
    deinit {
        refreshTask?.cancel()
    }
    
    func pauseTorrent(id: Int) async {
        do {
            try await service.pauseTorrent(id: id)
        } catch {
            errorMessage = "Failed to pause torrent: \(error.localizedDescription)"
            showError = true
        }
        await loadTorrents()
    }
    
    func resumeTorrent(id: Int) async {
        do {
            try await service.resumeTorrent(id: id)
        } catch {
            errorMessage = "Failed to resume torrent: \(error.localizedDescription)"
            showError = true
        }
        await loadTorrents()
    }
    
    func removeTorrent(id: Int) async {

        withAnimation {
            self.torrents.removeAll { $0.id == id }
        }
        
        DeletedTorrentsManager.instance.markAsDeleted(id: id)
        WidgetCenter.shared.reloadAllTimelines()
        
        do {
            try await service.removeTorrent(id: id)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await loadTorrents()
            
        } catch {
            print("⚠️ Silently handled TorBox Delete Crash for ID: \(id)")
        }
    }
}
