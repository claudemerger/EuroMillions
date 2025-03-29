//
//  EuroMillionsGame.swift
//  EuroMillions
//
//  Created on 24/03/2025.
//

import SwiftUI
import SwiftData

// MARK: - EuroMillions Game Class

/// Central game manager class responsible for generating, filtering and persisting EuroMillions number combinations.
/// This class coordinates between the drawing services, filtering rules, and storage mechanisms.
///
/// It is marked as @MainActor to ensure all UI updates and state changes happen on the main thread.
@MainActor
class EuroMillionsGame: ObservableObject {
    
    // MARK: - Properties
    
    /// App data service
    private let appDataService: AppDataService
    
    /// Data store with historical EuroMillions draw information
    //private let dataStoreBuilder: DataStoreBuilder
    
    /// View class that provides access to drawing algorithms
    private let drawingSelectorViewInstance: DrawingSelectorViewClass
    
    /// Repository for persisting and retrieving game combinations
    private let gameRepository: any GamePersistenceProtocol
    
    // MARK: - Filter State Properties
    
    /// When true, generated games won't contain duplicate numbers from historical draws
    @Published var noDoublon: Bool = true
    
    /// When true, ensures the generated combination has a balanced distribution of odd/even numbers
    @Published var isOdd: Bool = true
    
    /// When true, ensures numbers are evenly distributed across grid zones (10x5 grid)
    @Published var g10x5EvenlySplitted: Bool = true
    
    /// When true, ensures numbers are evenly distributed across grid zones (5x10 grid)
    @Published var g5x10EvenlySplitted: Bool = true
    
    /// When true, avoids sequences of consecutive numbers
    @Published var noSeries: Bool = true
    
    // MARK: - Game State Properties
    
    /// Currently loaded game combinations
    @Published var loadedGames: [[Int]] = []
    
    /// Counter for total draw attempts made during generation
    @Published var drawCount: Int = 0
    
    // MARK: - UI State Properties
    
    /// Flag indicating if game generation is in progress
    @Published var isGenerating: Bool = false
    
    /// Flag to show error alert
    @Published var showError: Bool = false
    
    /// Error message to display to user
    @Published var errorMessage: String = ""
    
    
    // MARK: - Singleton Support
    
    /// Singleton instance for global access
    static var gameInstance: EuroMillionsGame?
    

    // MARK: - Initialization
    
    /// Private initializer to support singleton pattern
    /// - Parameters:
    ///   - dataStoreBuilder: Data store with historical draw information
    ///   - drawingSelectorViewInstance: View class that provides access to drawing algorithms
    
    private init(appDataService: AppDataService) {
        self.appDataService = appDataService
        
        // Create a DrawingSelectorViewClass that's initialized with AppDataService
        let drawingSelector = DrawingSelectorViewClass()
        drawingSelector.initializeServices(dataStoreBuilder: appDataService.dataStore)
        self.drawingSelectorViewInstance = drawingSelector
        
        // Initialize the game repository
        do {
            self.gameRepository = try GameRepositoryFactory.createSwiftDataRepository()
            
            // Load previously saved games
            Task {
                await loadGamesFromPersistence()
            }
        } catch {
            print("⚠️ Failed to initialize game repository: \(error)")
            self.gameRepository = MockGameRepository()
        }
    }
    
    /// Factory method to access the singleton instance
    /// - Parameters:
    ///   - dataStoreBuilder: Data store with historical draw information
    ///   - drawingSelectorViewInstance: View class that provides access to drawing algorithms
    /// - Returns: The singleton instance of EuroMillionsGame

    static func gameInstance(appDataService: AppDataService) -> EuroMillionsGame {
        if gameInstance == nil {
            gameInstance = EuroMillionsGame(appDataService: appDataService)
        }
        return gameInstance!
    }

    
    // MARK: - Drawing Service Initialization
    
    /// Ensures the drawing service is initialized with data
    
    private func ensureDrawingServiceInitialized() {
        print("🔍 EuroMillionsGame: Checking if drawing service is initialized...")
        
        // Check if drawing service is already initialized
        if drawingSelectorViewInstance.drawingServiceInstance == nil {
            print("⚠️ EuroMillionsGame: Drawing service not initialized, initializing now...")
            
            // Print diagnostic information
            print("📊 EuroMillionsGame: DataStoreBuilder diagnostics:")
            print("📊 draws.count: \(appDataService.dataStore.draws.count)")
            print("📊 sortedDraws.count: \(appDataService.dataStore.sortedDraws.count)")
            
            // Always initialize the service, even if our local reference shows empty data
            // The DrawingSelectorViewClass may have access to the real data
            drawingSelectorViewInstance.initializeServices(
                dataStoreBuilder: appDataService.dataStore,
                verboseLogging: true
            )
            
            // Wait a short moment to ensure initialization completes
            // This is a workaround for timing issues
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Verify initialization worked
                if self.drawingSelectorViewInstance.drawingServiceInstance != nil {
                    print("✅ EuroMillionsGame: Drawing service initialized successfully")
                } else {
                    print("❌ EuroMillionsGame: Failed to initialize drawing service")
                }
            }
        } else {
            print("✅ EuroMillionsGame: Drawing service already initialized")
        }
    }
       
    // MARK: - Game Generation Support Functions
    
    /// Resets the draw counter to zero
    /// Called at the beginning of a new game generation session
    func resetCounters() {
        drawCount = 0
    }
    
    /// Increments the draw attempt counter
    /// Called after each draw attempt regardless of whether it passes filters
    func incrementDrawCount() {
        drawCount += 1
    }
    
    // MARK: - Main Game Generation Function (Optimized Version)
    
    /// Generates a specified number of valid EuroMillions number combinations

    func generateGames(count: Int,
                       strategy: DrawingStrategy,
                       preferredNumbers: [Int]? = nil,
                       context: ModelContext) async throws {
        
        print("func EuroMillionsGame>generateGames")
        
        // Log strategy information for debugging
        print("🎮 EuroMillionsGame: Generating games with strategy: \(strategy)")
        print("🔢 Preferred numbers: \(preferredNumbers ?? [])")
        
        // Validate request parameters
        guard count > 0 else { throw GameError.invalidNumberOfDraws }
        
        // Always ensure drawing service is initialized
        ensureDrawingServiceInitialized()
        
        // Wait a moment to allow initialization to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Update UI state
        isGenerating = true
        
        // Reset counters for fresh generation session
        resetCounters()
        
        // Create filter configuration from current settings
        let filterConfig = createFilterConfig()
        
        // Use either the drawingSelectorViewInstance's service or the appDataService's service
        if let drawingService = drawingSelectorViewInstance.drawingServiceInstance {
            print("✅ Using drawingSelectorViewInstance.drawingServiceInstance")
            try await generateWithService(
                drawingService,
                count: count,
                strategy: strategy,
                preferredNumbers: preferredNumbers,
                filterConfig: filterConfig
            )
        } else if let drawingService = appDataService.drawingService {
            print("✅ Using appDataService.drawingService")
            try await generateWithService(
                drawingService,
                count: count,
                strategy: strategy,
                preferredNumbers: preferredNumbers,
                filterConfig: filterConfig
            )
        } else {
            // No drawing service available
            print("❌ No drawing service available")
            await MainActor.run {
                self.isGenerating = false
                self.errorMessage = "Drawing service not available"
                self.showError = true
            }
            throw GameError.algorithmNotInitialized
        }
    }
        

    /// Helper method to create filter configuration
    private func createFilterConfig() -> DrawFilters.FilterConfig {
        return DrawFilters.FilterConfig(
            noDoublon: noDoublon,
            isOdd: isOdd,
            g10x5EvenlySplitted: g10x5EvenlySplitted,
            g5x10EvenlySplitted: g5x10EvenlySplitted,
            noSeries: noSeries
        )
    }

    /// Helper method to generate games with a specific service
    private func generateWithService(
        _ service: DrawingServiceClass,
        count: Int,
        strategy: DrawingStrategy,
        preferredNumbers: [Int]?,
        filterConfig: DrawFilters.FilterConfig
    ) async throws {
        
        // Pre-determine the list of numbers to use for all draws
        // Only relevant for userSelectedNumbers strategy
        let numbersForDraws = strategy == .userSelectedNumbers ? preferredNumbers : nil
        
        print("🎮 EuroMillionsGame: Starting generation loop for \(count) games")
        
        var validGames: [[Int]] = []
        var retryCount = 0
        let maxRetries = 1000 // Safety limit
        
        // Main generation loop - continue until we have enough valid combinations
        while validGames.count < count && retryCount < maxRetries {
            retryCount += 1
            
            do {
                // Generate a potential combination using the selected strategy
                let game = try service.generateDraw(
                    strategy: strategy,
                    list: numbersForDraws
                )
                
                if retryCount <= 3 || retryCount % 50 == 0 {
                    print("🎲 Generated draw attempt \(retryCount): \(game)")
                }

                // Track total draw attempts
                incrementDrawCount()
                
                // Apply filters to determine if this combination is valid
                if DrawFilters.checkGame(
                    game: game,
                    gameTable: validGames,
                    historicalDrawTable: appDataService.dataStore.draws,
                    config: filterConfig
                ) {
                    // Add to valid games collection
                    validGames.append(game)
                    
                    print("✅ Found valid game \(validGames.count)/\(count): \(game)")
                }
            } catch {
                print("❌ Drawing error on attempt \(retryCount): \(error)")
                
                // If we get repeated failures, add a small pause
                if retryCount % 10 == 0 {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second pause
                }
            }
        }
        
        if validGames.count < count {
            print("⚠️ Could only generate \(validGames.count) of \(count) requested games after \(retryCount) attempts")
            if validGames.isEmpty {
                throw GameError.maxAttemptsExceeded
            }
        }
        
        // Save the generated games to persistence
        do {
            try await saveGames(validGames, strategy: strategy.rawValue)
            
            await MainActor.run {
                self.loadedGames = validGames
                self.isGenerating = false
            }
            
            print("✅ Successfully generated and saved \(validGames.count) games")
        } catch {
            print("❌ Error saving games: \(error)")
            await MainActor.run { self.isGenerating = false }
            throw error
        }
    }
 
    
    // MARK: - Persistence Methods
    
    /// Saves generated game combinations to persistent storage
    /// - Parameters:
    ///   - games: Array of generated number combinations
    ///   - strategy: Identifier for the strategy used to generate these combinations
    /// - Throws: Error if saving fails
    
    private func saveGames(_ games: [[Int]], strategy: String) async throws {
        // Get the highest existing order index to ensure proper sequencing
        let highestIndex: Int
        
        // Try to get the highest index from SwiftData if available
        if let swiftDataRepo = gameRepository as? SwiftDataGameRepository {
            highestIndex = try await swiftDataRepo.getHighestOrderIndex()
        } else {
            // Fallback if repository doesn't support this operation
            highestIndex = -1
        }
        
        // Convert raw number arrays to EuroMillionsCombination objects
        let combinations = games.enumerated().map { index, numbers in
            EuroMillionsCombination(
                ballNumbers: numbers,
                starNumbers: [], // Star numbers not implemented yet
                creationDate: Date(),
                generationStrategy: strategy,
                orderIndex: highestIndex + index + 1  // Ensure sequential ordering
            )
        }
        
        // Save to the repository
        try await gameRepository.saveGames(combinations)
        
        // Reload from persistence to ensure data consistency
        await loadGamesFromPersistence()
        
        print("✅ Successfully saved \(games.count) games to persistence")
    }
    
    /// Loads saved game combinations from persistence into memory
    /// Updates the loadedGames published property
    
    private func loadGamesFromPersistence() async {
        do {
            // Load all saved combinations from the repository
            let combinations = try await gameRepository.loadGames()
            
            // Sort combinations by order index to maintain proper sequence
            let sortedCombinations = combinations.sorted { $0.orderIndex < $1.orderIndex }
            
            // Update UI state on the main thread
            await MainActor.run {
                self.loadedGames = sortedCombinations.map { $0.ballNumbers }
                //print("✅ Loaded \(self.loadedGames.count) games from persistence in order")
            }
        } catch {
            // Handle and display any errors
            print("❌ Error loading games from persistence: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load saved games: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
    
    /// Removes all saved game combinations from persistent storage
    /// - Throws: Error if deletion fails
    func clearAllGames() async {
        do {
            // Delete all games from repository
            try await gameRepository.deleteAllGames()
            
            // Update UI state on main thread
            await MainActor.run {
                self.loadedGames = []
                print("✅ All games cleared from persistence")
            }
        } catch {
            // Handle and display any errors
            print("❌ Error clearing games: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to clear games: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
}
    
// MARK: - Mock Repository Implementation

/// Simple in-memory implementation of GamePersistenceProtocol
/// Used as a fallback when SwiftData repository initialization fails
private class MockGameRepository: GamePersistenceProtocol {
    typealias GameCombinationType = EuroMillionsCombination
    
    /// In-memory storage for game combinations
    private var games: [EuroMillionsCombination] = []
    
    /// Saves game combinations to memory
    func saveGames(_ combinations: [EuroMillionsCombination]) async throws {
        self.games.append(contentsOf: combinations)
    }
    
    /// Retrieves all saved game combinations
    func loadGames() async throws -> [EuroMillionsCombination] {
        return games
    }
    
    /// Clears all saved game combinations
    func deleteAllGames() async throws {
        games = []
    }
    
    /// Returns the total number of saved combinations
    func getGameCount() async throws -> Int {
        return games.count
    }
    
    /// Filters saved combinations by creation date range
    func queryGamesByDateRange(startDate: Date, endDate: Date) async throws -> [EuroMillionsCombination] {
        return games.filter { $0.creationDate >= startDate && $0.creationDate <= endDate }
    }
    
    /// Filters saved combinations by generation strategy
    func queryGamesByStrategy(strategy: String) async throws -> [EuroMillionsCombination] {
        return games.filter { $0.generationStrategy == strategy }
    }
}
