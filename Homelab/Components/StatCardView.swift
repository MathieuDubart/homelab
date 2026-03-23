//
//  StatCardView.swift
//  Homelab
//
//  Created by Mathieu Dubart on 23/03/2026.
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(value)%")
                .font(Theme.valueFont)
            ProgressView(value: progress)
                .tint(color)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}
