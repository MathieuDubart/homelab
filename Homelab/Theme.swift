//
//  Theme.swift
//  Homelab
//
//  Created by Mathieu Dubart on 23/03/2026.
//


import SwiftUI

enum Theme {
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let accent = Color.blue
    static let coolifyAccent = Color.orange
    static let torboxAccent = Color.purple
    
    static let titleFont = Font.system(.title2, design: .rounded).bold()
    static let valueFont = Font.system(.subheadline, design: .monospaced).bold()
}
