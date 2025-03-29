//
//  DrawingService.swift
//  EuroMillions
//
//  Created on 24/03/2025.
//

import Foundation
import Combine

// MARK: - Drawing Service Class

/// A service class responsible for generating EuroMillions number draws using various algorithms.
/// This class acts as a central coordinator for different drawing strategies and maintains
/// the necessary state and algorithms for number generation.
///
/// The class is marked with @MainActor to ensure all operations occur on the main thread,
/// which is important for UI updates and data consistency.

@MainActor
class DrawingServiceClass {
    
    // MARK: - Properties
    
    /// Data store containing historical draws and other game data
    private let dataStoreBuilder: DataStoreBuilder
    
    /// Basic algorithm for simple random drawing
    private let numberDrawingAlgorithm: NumberDrawingAlgorithm
    
    /// Advanced algorithm that draws one number from each column of historical draws
    private var columnBasedDrawingAlgorithm: ColumnBasedDrawingAlgorithm?
    
    /// Algorithm that considers number spread patterns across columns in historical draws
    private var columnSpreadBasedDrawingAlgorithm: ColumnSpreadBasedDrawingAlgorithm?
    
    /// Algorithm that bases drawing probability on the frequency history of each number
    private var columnDrawingHistoryAlgorithm: ColumnDrawingBasedOnNumberDrawHistoryAlgorithm?
    
    /// Cached list of valid EuroMillions numbers (1-50)
    /// Stored as a property to avoid recreating it for each simple draw
    private let defaultNumbersList = NumberDrawingAlgorithm.defaultNumbersList()
    
    /// Flag to enable detailed logging during drawing operations
    private let verboseLogging: Bool
    
    /// Collection to store and manage Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Debug property
    private var lastObservedDrawCount: Int = -1
    
    // MARK: - Public Properties
    
    /// The total number of historical draws available for algorithm use
    var historicalDrawsCount: Int { dataStoreBuilder.sortedDraws.count }
    
    // MARK: - Initialization
    
    /// Initializes the drawing service with the necessary data store and configuration
    /// - Parameters:
    ///   - dataStoreBuilder: The data source containing historical draws
    ///   - verboseLogging: Whether to enable detailed logging (defaults to false)
    
    init(dataStoreBuilder: DataStoreBuilder, verboseLogging: Bool = true) {
        self.dataStoreBuilder = dataStoreBuilder
        self.verboseLogging = verboseLogging
        
        // debug
        // Log initial state immediately
        print("🔍 DrawingServiceClass INIT - Current state of dataStoreBuilder:")
        print("🔍 dataStoreBuilder.draws.count: \(dataStoreBuilder.draws.count)")
        print("🔍 dataStoreBuilder.sortedDraws.count: \(dataStoreBuilder.sortedDraws.count)")
        
        // Store current count for comparison
        self.lastObservedDrawCount = dataStoreBuilder.sortedDraws.count
        // end of debug
        
        
        // Initialize the basic drawing algorithm
        self.numberDrawingAlgorithm = NumberDrawingAlgorithm()
        
        
        // debug
        // Initialize advanced algorithms if data is available
         if !dataStoreBuilder.sortedDraws.isEmpty {
             print("📊 DrawingServiceClass init - Initializing with \(dataStoreBuilder.sortedDraws.count) draws")
             initializeColumnAlgorithms()
         } else {
             print("⚠️ DrawingServiceClass init - NO DATA AVAILABLE - sortedDraws is empty!")
             // Try to diagnose why data is empty
             dataStoreBuilder.printDiagnostics()
         }
        // end of debug
        
    }
    
    // MARK: - Private Setup Methods
    
    private func setupDataStoreObservation() {
        print("🔄 DrawingServiceClass - Setting up observation")
        
        // First create a publisher that monitors all relevant properties
        let dataPublisher = dataStoreBuilder.$sortedDraws
            .combineLatest(dataStoreBuilder.$draws, dataStoreBuilder.$isLoading)
        
        dataPublisher
            .sink { [weak self] (sortedDraws, draws, isLoading) in
                guard let self = self else { return }
                
                print("📌 OBSERVATION UPDATE:")
                print("📌 sortedDraws.count: \(sortedDraws.count), previous: \(self.lastObservedDrawCount)")
                print("📌 draws.count: \(draws.count)")
                print("📌 isLoading: \(isLoading)")
                
                // Check if the data has changed
                if sortedDraws.count != self.lastObservedDrawCount {
                    print("🔄 DrawingServiceClass - Data changed from \(self.lastObservedDrawCount) to \(sortedDraws.count) draws")
                    
                    // Update our tracker
                    self.lastObservedDrawCount = sortedDraws.count
                    
                    // Check if loading is complete and we have data
                    if !isLoading && !sortedDraws.isEmpty {
                        print("✅ DrawingServiceClass - Loading complete, initializing algorithms with \(sortedDraws.count) draws")
                        self.initializeColumnAlgorithms()
                    } else if !isLoading && sortedDraws.isEmpty {
                        print("⚠️ DrawingServiceClass - Loading complete but NO DATA AVAILABLE")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Drawing Methods
    
    /// Generates a set of EuroMillions numbers using the specified drawing strategy
    ///
    /// This method serves as the main entry point for number generation, dispatching
    /// to the appropriate algorithm based on the requested strategy.
    ///
    /// - Parameters:
    ///   - strategy: The drawing strategy to use (simple, user-selected, or various column-based approaches)
    ///   - list: Optional custom list of numbers to draw from (required for userSelectedNumbers strategy)
    ///   - count: Number of numbers to generate (defaults to 5, the standard for EuroMillions)
    /// - Throws: GameError if there's an issue with the drawing process
    /// - Returns: An array of integers representing the drawn numbers
    
    func generateDraw(strategy: DrawingStrategy, list: [Int]? = nil, count: Int = 5) throws -> [Int] {
        
        if verboseLogging {
            print("📊 DrawingServiceClass generateDraw - Called with strategy:", strategy)
            //print("📊 DrawingServiceClass generateDraw - Has \(dataStoreBuilder.sortedDraws.count) historical draws")
        }
        
        
        print("🎲 generateDraw - Strategy: \(strategy), Current data counts:")
        print("🎲 dataStoreBuilder.draws.count: \(dataStoreBuilder.draws.count)")
        print("🎲 dataStoreBuilder.sortedDraws.count: \(dataStoreBuilder.sortedDraws.count)")
        
        if strategy != .simple && strategy != .userSelectedNumbers {
            if dataStoreBuilder.sortedDraws.isEmpty {
                print("⚠️⚠️⚠️ ERROR: Attempting to use historical data strategy but no data available!")
                dataStoreBuilder.printDiagnostics()
            } else {
                print("✅ Historical data is available for strategy")
                
                // Check if algorithms are initialized
                print("🔍 columnBasedDrawingAlgorithm: \(columnBasedDrawingAlgorithm != nil ? "initialized" : "NULL")")
                print("🔍 columnSpreadBasedDrawingAlgorithm: \(columnSpreadBasedDrawingAlgorithm != nil ? "initialized" : "NULL")")
                print("🔍 columnDrawingHistoryAlgorithm: \(columnDrawingHistoryAlgorithm != nil ? "initialized" : "NULL")")
            }
        }
        
        
        switch strategy {
            
        case .simple:
            // Use the basic random number generator with the default range (1-50)
            if verboseLogging {
                print("Using cached defaultNumbersList with \(defaultNumbersList.count) numbers")
            }
            return try numberDrawingAlgorithm.generateDraw(list: defaultNumbersList, count: count)
            
        case .userSelectedNumbers:
            // Validate that the user has provided a custom list of numbers
            guard let list = list, !list.isEmpty else {
                throw GameError.invalidNumberRange
            }
            
            if verboseLogging {
                print("Using cached defaultNumbersList with \(list.count) numbers")
            }
            
            // Draw from the user-provided list
            return try numberDrawingAlgorithm.generateDraw(list: list, count: count)
            
        case .fullColumnWeighted:
            // Check if we have enough historical data for this strategy
            if dataStoreBuilder.sortedDraws.isEmpty {
                if verboseLogging {
                    print("⚠️ Warning: No historical draws available for column weighted strategy, falling back to simple drawing")
                    dataStoreBuilder.printDiagnostics()
                }
                // Fallback to simple drawing if no historical data is available
                return try numberDrawingAlgorithm.generateDraw(list: defaultNumbersList, count: count)
            }
            
            // Ensure the algorithm is initialized
            guard let algorithm = columnBasedDrawingAlgorithm else {
                throw GameError.algorithmNotInitialized
            }
            
            // Generate draw using the column-based algorithm
            return try algorithm.generateDraw(table: dataStoreBuilder.sortedDraws, count: count)
            
        case .reducedColumnWeighted:
            // Check if we have enough historical data for this strategy
            if dataStoreBuilder.sortedDraws.isEmpty {
                if verboseLogging {
                    print("⚠️ Warning: No historical draws available for column spread strategy, falling back to simple drawing")
                    dataStoreBuilder.printDiagnostics()
                }
                // Fallback to simple drawing if no historical data is available
                return try numberDrawingAlgorithm.generateDraw(list: defaultNumbersList, count: count)
            }
            
            // Ensure the algorithm is initialized
            guard let algorithm = columnSpreadBasedDrawingAlgorithm else {
                throw GameError.algorithmNotInitialized
            }
            
            // Generate draw using the column spread algorithm
            return try algorithm.generateDraw(table: dataStoreBuilder.reducedDraws, count: count)
            
        case .columnDrawingHistory:
            // Check if we have enough historical data for this strategy
            if dataStoreBuilder.sortedDraws.isEmpty {
                if verboseLogging {
                    print("⚠️ Warning: No historical draws available for column history strategy, falling back to simple drawing")
                    dataStoreBuilder.printDiagnostics()
                }
                // Fallback to simple drawing if no historical data is available
                return try numberDrawingAlgorithm.generateDraw(list: defaultNumbersList, count: count)
            }
            
            // Ensure the algorithm is initialized
            guard let algorithm = columnDrawingHistoryAlgorithm else {
                throw GameError.algorithmNotInitialized
            }
            
            if verboseLogging {
                print("📊 DrawingService - Using column drawing history")
                print("📊 DrawingService - First draw:", dataStoreBuilder.sortedDraws.first ?? [])
            }
            
            // Generate draw using the column drawing history algorithm
            return try algorithm.generateDraw(table: dataStoreBuilder.sortedDraws, count: count)
        }
    }
    
    // Enhanced initializeColumnAlgorithms
    private func initializeColumnAlgorithms() {
        print("🔄 initializeColumnAlgorithms - Starting initialization")
        print("🔄 dataStoreBuilder.sortedDraws.count: \(dataStoreBuilder.sortedDraws.count)")
        
        // Only initialize if we have data
        if !dataStoreBuilder.sortedDraws.isEmpty {
            print("✅ initializeColumnAlgorithms - Data available, initializing algorithms")
            
            if let firstDraw = dataStoreBuilder.sortedDraws.first {
                print("📊 First sorted draw: \(firstDraw)")
            }
            
            // Initialize the column-based drawing algorithm
            self.columnBasedDrawingAlgorithm = ColumnBasedDrawingAlgorithm(
                historicalDraws: dataStoreBuilder.sortedDraws,
                verboseLogging: verboseLogging
            )
            
            // Initialize the column spread drawing algorithm
            self.columnSpreadBasedDrawingAlgorithm = ColumnSpreadBasedDrawingAlgorithm(
                historicalDraws: dataStoreBuilder.sortedDraws)
            
            // Initialize the column drawing history algorithm
            self.columnDrawingHistoryAlgorithm = ColumnDrawingBasedOnNumberDrawHistoryAlgorithm(
                historicalDraws: dataStoreBuilder.sortedDraws)
            
            print("✅ initializeColumnAlgorithms - All algorithms initialized successfully")
        } else {
            // Log warning and set algorithms to nil if no data is available
            print("⚠️ initializeColumnAlgorithms - NOT INITIALIZING: sortedDraws is EMPTY")
            self.columnBasedDrawingAlgorithm = nil
            self.columnSpreadBasedDrawingAlgorithm = nil
            self.columnDrawingHistoryAlgorithm = nil
        }
    }
    
}
