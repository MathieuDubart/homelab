//
//  TorBoxView.swift
//  Homelab
//

import SwiftUI

struct TorBoxView: View {
    @AppStorage("torbox_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var torboxToken: String = ""

    @StateObject private var viewModel: TorBoxViewModel

    init() {
        let token = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")?
            .string(forKey: "torbox_token") ?? ""
        _viewModel = StateObject(wrappedValue: TorBoxViewModel(token: token))
    }

    private var sortedTorrents: [TorBoxItem] {
        viewModel.torrents.sorted { ($0.progress ?? 0) > ($1.progress ?? 0) }
    }

    var body: some View {
        List {
            Section {
                EmptyView()
            } header: {
                header
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            if viewModel.torrents.isEmpty {
                emptyState
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 0, trailing: 20))
            } else {
                ForEach(sortedTorrents) { torrent in
                    TorBoxRow(torrent: torrent)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .swipeActions(edge: .leading) {
                            leadingSwipeActions(for: torrent)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Haptics.fire(.error)
                                Task { await viewModel.removeTorrent(id: torrent.id) }
                            } label: {
                                Label(String(localized: "remove"), systemImage: "trash.fill")
                            }
                            .tint(Palette.ember)
                        }
                }
            }

            // Bottom spacer so last row clears the floating tab bar
            Color.clear
                .frame(height: 96)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .refreshable {
            Haptics.fire(.refresh)
            await viewModel.loadTorrents()
            Haptics.fire(.success)
        }
        .onAppear {
            Task { await viewModel.loadTorrents() }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    PulseDot(tint: activeCount > 0 ? Palette.plasma : Palette.mint)
                    Text(activeCount > 0 ? "\(activeCount) ACTIVE" : "IDLE")
                        .font(DSFont.caption)
                        .tracking(1.4)
                        .foregroundStyle(activeCount > 0 ? Palette.plasma : Palette.mint)
                }
                Text(String(localized: "torboxStorage"))
                    .font(DSFont.title)
                    .foregroundStyle(.white)
                Text("\(viewModel.torrents.count) \(String(localized: "storage").lowercased())")
                    .font(DSFont.monoSmall)
                    .foregroundStyle(Ink.dim)
            }
            Spacer()
            refreshButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var refreshButton: some View {
        Button {
            Haptics.fire(.softImpact)
            Task { await viewModel.loadTorrents() }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 42, height: 42)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
        }
        .pressable()
    }

    // MARK: - Swipe actions

    @ViewBuilder
    private func leadingSwipeActions(for torrent: TorBoxItem) -> some View {
        if torrent.status == .downloading {
            Button {
                Haptics.fire(.toggleOff)
                Task { await viewModel.pauseTorrent(id: torrent.id) }
            } label: {
                Label(String(localized: "pause"), systemImage: "pause.fill")
            }
            .tint(Palette.solar)
        } else if torrent.status == .paused {
            Button {
                Haptics.fire(.toggleOn)
                Task { await viewModel.resumeTorrent(id: torrent.id) }
            } label: {
                Label(String(localized: "resume"), systemImage: "play.fill")
            }
            .tint(Palette.mint)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        GlowCard(tint: Palette.plasma) {
            VStack(spacing: 16) {
                Image(systemName: "tray.full")
                    .font(.system(size: 46))
                    .foregroundStyle(
                        LinearGradient(colors: [Palette.plasma, Palette.electric],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .symbolEffect(.pulse, options: .repeating)
                Text(String(localized: "noActiveTransfer"))
                    .font(DSFont.title)
                    .foregroundStyle(.white)
                Text(String(localized: "addTorrents"))
                    .font(DSFont.body)
                    .foregroundStyle(Ink.dim)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Helpers

    private var activeCount: Int {
        viewModel.torrents.filter {
            $0.status == .downloading || $0.status == .checking
        }.count
    }
}

#Preview {
    ZStack {
        MeshBackground(tints: [Palette.plasma, Palette.electric, Palette.solar])
        TorBoxView()
    }
    .preferredColorScheme(.dark)
}
