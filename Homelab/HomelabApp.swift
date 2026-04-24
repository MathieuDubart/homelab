// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  HomelabApp.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//

import SwiftUI
import UserNotifications

@main
struct HomelabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: requestNotificationPermission)
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if error != nil {
            }
        }
    }
}
