// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  CoolifyResource.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//


import Foundation

struct CoolifyServiceResource: Codable, Identifiable {
    let uuid: String
    let name: String
    let status: String?
    
    var id: String { uuid }
}
