// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  TorBoxResponse.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//


struct TorBoxResponse: Codable {
    let success: Bool
    let data: [TorBoxItem]
}