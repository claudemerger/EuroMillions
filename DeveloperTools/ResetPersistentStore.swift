//
//  ResetPersistentStore.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 20/03/2025.
//

import Foundation

// MARK: - Reset Persistent Store (FOR DEVELOPMENT ONLY)
func resetPersistentStore() {
    // Get the URL for the default SwiftData store
    let storeURL = URL.applicationSupportDirectory.appendingPathComponent("default.store")
    
    // Attempt to remove the store file
    do {
        try FileManager.default.removeItem(at: storeURL)
        print("✅ Successfully reset persistent store at: \(storeURL.path)")
    } catch {
        print("❌ Failed to reset persistent store: \(error.localizedDescription)")
    }
}
