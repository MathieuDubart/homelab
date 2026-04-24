// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Mathieu Dubart
//
//  DeletedTorrentsManager.swift
//  Homelab
//
//  Created by Mathieu Dubart on 20/03/2026.
//

import Foundation
import SwiftUI

class DeletedTorrentsManager {
    static let instance = DeletedTorrentsManager()
    
    private let sharedSuite = UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")
    private let storageKey = "deleted_torrent_ids"
    
    func getDeletedIDs() -> Set<Int> {
        let array = sharedSuite?.array(forKey: storageKey) as? [Int] ?? []
        return Set(array)
    }
    
    func markAsDeleted(id: Int) {
        var currentIDs = getDeletedIDs()
        currentIDs.insert(id)
        sharedSuite?.set(Array(currentIDs), forKey: storageKey)
    }
    
    func clean(keeping activeIDs: Set<Int>) {
        let currentIDs = getDeletedIDs()

        let intersection = currentIDs.intersection(activeIDs)
        sharedSuite?.set(Array(intersection), forKey: storageKey)
        
        if intersection.count < currentIDs.count {
            print("🧹 DeletedTorrentsManager : Cleaned \(currentIDs.count - intersection.count) old phantom IDs.")
        }
    }
    
    func reset() {
        sharedSuite?.removeObject(forKey: storageKey)
    }
    

}
