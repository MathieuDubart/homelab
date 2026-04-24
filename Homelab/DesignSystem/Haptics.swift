// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  Haptics.swift
//  Homelab
//

import UIKit
import SwiftUI

enum Haptics {
    enum Event {
        case tabSwitch
        case selection
        case toggleOn
        case toggleOff
        case refresh
        case success
        case warning
        case error
        case hardImpact
        case softImpact
    }

    /// Fire a haptic event. Safe to call from any thread.
    static func fire(_ event: Event) {
        DispatchQueue.main.async {
            switch event {
            case .tabSwitch:
                let g = UIImpactFeedbackGenerator(style: .rigid)
                g.prepare()
                g.impactOccurred(intensity: 0.85)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .toggleOn:
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred(intensity: 1.0)
            case .toggleOff:
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred(intensity: 0.7)
            case .refresh:
                let g = UIImpactFeedbackGenerator(style: .soft)
                g.impactOccurred(intensity: 0.6)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .hardImpact:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .softImpact:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
        }
    }
}
