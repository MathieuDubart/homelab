//
//  TorBoxRow.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


import SwiftUI

struct TorBoxRow: View {
    let torrent: TorBoxItem
    
    private let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 75)
                .overlay(
                    Image(systemName: "popcorn.fill")
                        .foregroundColor(.secondary)
                )
            
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Text(torrent.cleanName)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                        .frame(width: 6)
                    
                    Text(torrent.status.rawValue.capitalized)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(torrent.status.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(torrent.status.color.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(torrent.releaseYear)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                    .frame(height: 18)
                
                if torrent.status == .downloading, let speed = torrent.downloadSpeed {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 10))
                        Text("\(byteCountFormatter.string(fromByteCount: speed))/s")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                
                
                ProgressView(value: torrent.progress ?? 0)
                    .progressViewStyle(.linear)
                    .tint(torrent.status.color)
                    .frame(height: 2)
            }
            .padding(.vertical, 8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
