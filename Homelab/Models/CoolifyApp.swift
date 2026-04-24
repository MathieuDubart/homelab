// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  CoolifyModel.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//

import Foundation

struct CoolifyApp: Codable, Identifiable {
    let id: Int
    let uuid: String
    let name: String
    let status: String?
    let type: String?
}
