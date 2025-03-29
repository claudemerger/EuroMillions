//
//  GameRepositoryFactory.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//
// File: DataPersistence/GameRepositoryFactory.swift

import Foundation

// MARK: - Enum

enum GameRepositoryError: Error {
    case initializationFailed(String)
}


// MARK: - Class Game Repository Factory

class GameRepositoryFactory {
    
    @MainActor static func createSwiftDataRepository() throws -> SwiftDataGameRepository {
        do {
            return try SwiftDataGameRepository()
        } catch {
            throw GameRepositoryError.initializationFailed("Failed to create SwiftData repository: \(error.localizedDescription)")
        }
    }
    // Add more repository types here in the future if needed
}
