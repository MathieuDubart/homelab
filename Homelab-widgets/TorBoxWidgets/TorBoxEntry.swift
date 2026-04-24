// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxEntry.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//
import WidgetKit

struct TorBoxEntry: TimelineEntry {
    let date: Date
    let torrents: [TorBoxItem]
}
