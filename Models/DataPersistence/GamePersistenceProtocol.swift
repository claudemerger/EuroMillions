//
//  GamePersistenceProtocol.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//

import Foundation


// MARK: - Game Persistence Protocol

/// Protocol defining the persistence operations for game combinations
protocol GamePersistenceProtocol {
    /// The type of game combination being stored
    associatedtype GameCombinationType
    
    /// Save game combinations to persistent storage
    /// - Parameter combinations: Array of game combinations to save
    /// - Returns: Boolean indicating success
    func saveGames(_ combinations: [EuroMillionsCombination]) async throws
    
    /// Load all stored game combinations
    /// - Returns: Array of stored game combinations
    func loadGames() async throws -> [EuroMillionsCombination]
    
    /// Delete all stored game combinations
    func deleteAllGames() async throws
    
    /// Get the count of stored game combinations
    /// - Returns: Number of stored combinations
    func getGameCount() async throws -> Int
    
    /// Query games by creation date range
    /// - Parameters:
    ///   - startDate: Beginning of date range
    ///   - endDate: End of date range
    /// - Returns: Array of matching game combinations
    func queryGamesByDateRange(startDate: Date, endDate: Date) async throws -> [GameCombinationType]
    
    /// Query games by generation strategy
    /// - Parameter strategy: The strategy used to generate games
    /// - Returns: Array of matching game combinations
    func queryGamesByStrategy(strategy: String) async throws -> [GameCombinationType]
}
