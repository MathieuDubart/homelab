// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxStorageWidget.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//

import SwiftUI
import WidgetKit

struct TorBoxStorageWidgets: Widget {
    let kind: String = "TorBoxStorageWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TorBoxProvider()) { entry in
            TorBoxWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TorBox Storage")
        .description("Track and control your downloads.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
