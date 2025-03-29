//
//  GamePersistenceManager.swift
//  EuroMillions
//
//  Created on 19/03/2025.
//

import Foundation

/// A manager class that handles the persistence of game data
/// Responsible for:
/// - Saving game tables to disk
/// - Loading game tables from disk
/// - Managing game file locations
/// - Handling read/write operations
class GamePersistenceManager {
    // MARK: - Singleton
    
    /// Shared instance for the application
    static let shared = GamePersistenceManager()
    
    // MARK: - File Paths
    
    /// Base directory URL for all saved games
    private var gamesDirectoryURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gamesDirectory = documentsDirectory.appendingPathComponent("EuroMillions/Games", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: gamesDirectory.path) {
            try? FileManager.default.createDirectory(at: gamesDirectory, withIntermediateDirectories: true)
        }
        
        return gamesDirectory
    }
    
    /// Base directory URL for backtest results
    private var backtestDirectoryURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let backtestDirectory = documentsDirectory.appendingPathComponent("EuroMillions/Backtests", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: backtestDirectory.path) {
            try? FileManager.default.createDirectory(at: backtestDirectory, withIntermediateDirectories: true)
        }
        
        return backtestDirectory
    }
    
    // MARK: - Private Init
    
    private init() {
        // Initialize the manager
        print("📁 GamePersistenceManager: Initialized with storage at \(gamesDirectoryURL.path)")
    }
    
    // MARK: - Public Methods
    
    /// Saves a game table to disk
    /// - Parameters:
    ///   - gameTable: The game table to save
    ///   - name: Unique name for the game table
    ///   - isBacktest: Whether this is a backtest or regular game
    /// - Throws: Error if saving fails
    func saveGameTable(_ gameTable: GameTable, withName name: String, isBacktest: Bool = false) throws {
        // Determine the directory to save to
        let directoryURL = isBacktest ? backtestDirectoryURL : gamesDirectoryURL
        
        // Create the file URL
        let fileURL = directoryURL.appendingPathComponent("\(name).json")
        
        // Encode the game table to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(gameTable)
        
        // Write to disk
        try data.write(to: fileURL)
        
        print("💾 GamePersistenceManager: Saved game table '\(name)' to \(fileURL.path)")
    }
    
    /// Loads a game table from disk
    /// - Parameters:
    ///   - name: Name of the game table to load
    ///   - isBacktest: Whether this is a backtest or regular game
    /// - Returns: The loaded game table
    /// - Throws: Error if loading fails
    func loadGameTable(withName name: String, isBacktest: Bool = false) throws -> GameTable {
        // Determine the directory to load from
        let directoryURL = isBacktest ? backtestDirectoryURL : gamesDirectoryURL
        
        // Create the file URL
        let fileURL = directoryURL.appendingPathComponent("\(name).json")
        
        // Read the data
        let data = try Data(contentsOf: fileURL)
        
        // Decode the game table
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let gameTable = try decoder.decode(GameTable.self, from: data)
        
        print("📂 GamePersistenceManager: Loaded game table '\(name)' from \(fileURL.path)")
        
        return gameTable
    }
    
    /// Lists all saved game tables
    /// - Parameter isBacktest: Whether to list backtest tables or regular game tables
    /// - Returns: Array of game table names
    func listGameTables(isBacktest: Bool = false) -> [String] {
        // Determine the directory to list
        let directoryURL = isBacktest ? backtestDirectoryURL : gamesDirectoryURL
        
        // Get all files in directory
        let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil
        )
        
        // Extract file names without extension
        return fileURLs?.filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent } ?? []
    }
    
    /// Deletes a game table
    /// - Parameters:
    ///   - name: Name of the game table to delete
    ///   - isBacktest: Whether this is a backtest or regular game
    /// - Throws: Error if deletion fails
    func deleteGameTable(withName name: String, isBacktest: Bool = false) throws {
        // Determine the directory
        let directoryURL = isBacktest ? backtestDirectoryURL : gamesDirectoryURL
        
        // Create the file URL
        let fileURL = directoryURL.appendingPathComponent("\(name).json")
        
        // Delete the file
        try FileManager.default.removeItem(at: fileURL)
        
        print("🗑️ GamePersistenceManager: Deleted game table '\(name)' from \(fileURL.path)")
    }
}
