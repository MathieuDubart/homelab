//
//  TorBoxView.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import SwiftUI

struct TorBoxView: View {
    @AppStorage("torbox_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    var torboxToken: String = ""
    
    @StateObject private var viewModel: TorBoxViewModel
    
    init() {
        let token = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")?.string(forKey: "torbox_token") ?? ""
        _viewModel = StateObject(wrappedValue: TorBoxViewModel(token: token))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.torrents.isEmpty {
                    emptyStateView
                } else {
                    torrentListView
                }
            }
            .navigationTitle(LocalizedStringResource.torboxStorage)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                }
            }
            .onAppear {
                Task { await viewModel.loadTorrents() }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                if let errorMessage = viewModel.errorMessage { Text(errorMessage) }
            }
        }
        .refreshable {
            await viewModel.loadTorrents()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(LocalizedStringResource.noActiveTransfer)
                .font(.headline)
            Text(LocalizedStringResource.addTorrents)
                .font(.subheadline)
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    private var torrentListView: some View {
        let sortedTorrents = viewModel.torrents.sorted { $0.progress ?? 0 > $1.progress ?? 0 }
        
        return ForEach(sortedTorrents) { torrent in
            TorBoxRow(torrent: torrent)
                .listRowBackground(Color(.secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
                .swipeActions(edge: .leading) {
                    leadingSwipeActions(for: torrent)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        Task {
                            await viewModel.removeTorrent(id: torrent.id)
                            generator.impactOccurred()
                        }
                    } label: {
                        Label(LocalizedStringResource.remove, systemImage: "trash.fill")
                    }
                    .tint(.red)
                }
        }
    }
    
    @ViewBuilder
    private func leadingSwipeActions(for torrent: TorBoxItem) -> some View {
        if torrent.status == .downloading {
            Button {
                Task { await viewModel.pauseTorrent(id: torrent.id) }
            } label: {
                Label(LocalizedStringResource.pause, systemImage: "pause.fill")
            }
            .tint(.orange)
        } else if torrent.status == .paused {
            Button {
                Task { await viewModel.resumeTorrent(id: torrent.id) }
            } label: {
                Label(LocalizedStringResource.resume, systemImage: "play.fill")
            }
            .tint(.green)
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task { await viewModel.loadTorrents() }
        } label: {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}
