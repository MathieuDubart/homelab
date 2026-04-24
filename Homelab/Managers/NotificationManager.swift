// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  NotificationManager.swift
//  Homelab
//
//  Created by Mathieu Dubart on 19/03/2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func sendDownloadCompleteNotification(torrentName: String) {
        let body = "\(torrentName) \(LocalizedStringResource.downloadCompleteDetails)"
        sendAlert(title: "downloadComplete", body: body)
    }
    
    func sendAlert(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
