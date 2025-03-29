//
//  DataStoreBuilder.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 17/03/2025.
//

import Foundation


/// Central data store for the EuroMillions application
/// Responsible for:
/// - Loading EuroMillions draw data from the EuroMillionsLoader package
/// - Storing and organizing draw numbers, stars, and dates
/// - Providing access methods for all modules to retrieve draw data
/// - Managing loading states and error handling
///
@MainActor
class DataStoreBuilder: ObservableObject {
    // MARK: - Published Properties
    
    /// Storage for the 5 main numbers of each draw
    /// Organized as an array of arrays, with index 0 being the most recent draw
    @Published var draws: [[Int]] = []
    
    /// Sorted draws
    @Published var sortedDraws: [[Int]] = []
    
    /// Reduced draws: array reduced to the draws until all numbers have been drawn once
    @Published var reducedDraws: [[Int]] = []
    
    /// Storage for the 2 star numbers of each draw
    /// Organized as an array of arrays, with index 0 being the most recent draw
    @Published var stars: [[Int]] = []
    
    /// Sorted stars
    @Published var sortedStars: [[Int]] = []
    
    /// Storage for prize information (not yet implemented)
    /// Will be used to store winning amounts for different prize tiers
    @Published var wins: [[Double]] = []
    
    /// Dates corresponding to each draw
    /// Indexed the same as draws and stars arrays
    @Published var drawDates: [Date] = []
    
    /// Indicates whether data is currently being loaded
    /// Used by views to display loading indicators
    @Published var isLoading: Bool = false
    
    /// Error message if data loading fails
    /// Contains details about what went wrong
    @Published var errorMessage: String = ""
    
    /// Flag indicating if an error has occurred
    /// Used by views to display error alerts
    @Published var hasError: Bool = false
    
    /// Data parsing statistics
    @Published var parsingStats: ParsingStatistics = ParsingStatistics()
    
    /// Distance Table
    @Published var distanceTable: [[Int]] = []
    
    /// Weight Table
    @Published var weightTable: [[Int]] = []
    
    
    // MARK: - Private Properties
    
    // Provides access to dataParser
    private let dataParser = DataParser()
    
    
    // MARK: - Models
    
    /// Statistics about the parsing process
    struct ParsingStatistics {
        var totalRows: Int = 0
        var processedRows: Int = 0
        var historicalRows: Int = 0
        var currentRows: Int = 0
        var skippedRows: Int = 0
        var parseTime: TimeInterval = 0
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize with empty data
    }
    
    
    // MARK: - Public Methods
    
    /// Builds the data store from a parsed database
    /// - Parameter dataBase: The CSV database content as a string
    
    public func buildDataStore(dataBase: String) async throws {
        // Uncomment for detailed logging
        //print("🔄 function: buildDataStore: ...")
        
        // Set status
        isLoading = true
        hasError = false
        errorMessage = ""
        
        // Clear existing data
        draws = []
        stars = []
        wins = []
        drawDates = []
        sortedDraws = []
        sortedStars = []
        
        do {
            //print("🔍 buildDataStore: Starting parsing data...")
            let startTime = Date()
            
            // Parse the database
            let (parsedDraws, parsedStars, parsedWins) = try await dataParser.parseDataBase(dataBase)
            
            // Calculate parsing time
            let parseTime = Date().timeIntervalSince(startTime)
            
            // Store the parsed data
            drawDates = parsedDraws.map { $0.date }
            draws = parsedDraws.map { $0.numbers }
            stars = parsedStars.map { $0.stars }
            wins = parsedWins.map { $0.wins }
            
            // Generate sorted draws
            sortedDraws = draws.map { $0.sorted() }
            
            // Generate reduced draws (limited to the draws until all numbers have appeared once) and sorted
            reducedDraws = generateReducedDraws(draws: draws).map { $0.sorted() }
            
            // Generate sorted stars
            sortedStars = stars.map { $0.sorted() }
            
            // generate distance table
            distanceTable = try GenerateDistanceTable.calculateNumberDistance(table: draws)
            //print("function: loaded all data: distance table count:  \(distanceTable.count)")
            
            // generate weight table
            weightTable = try GenerateWeightTable.calculateNumberWeight(table: draws, distance: 146)
            //print("function: loaded all data: weight table count:  \(weightTable.count)")
            
            
            // Update parsing statistics
            parsingStats = ParsingStatistics(
                totalRows: parsedDraws.count + parsedStars.count + parsedWins.count,
                processedRows: parsedDraws.count,
                historicalRows: parsedWins.filter { $0.wins.isEmpty }.count,
                currentRows: parsedWins.filter { !$0.wins.isEmpty }.count,
                skippedRows: 0, // This would need to be passed from the parser
                parseTime: parseTime
            )
            
             /*
             print("✅ buildDataStore: Data processing complete")
             print("📊 Parsing statistics:")
             print("  - Total records: \(draws.count)")
             print("  - Parsing time: \(String(format: "%.2f", parseTime)) seconds")
             */
            
            isLoading = false
        } catch {
            print("❌ buildDataStore: Error parsing data: \(error)")
            errorMessage = "Failed to parse data: \(error.localizedDescription)"
            hasError = true
            isLoading = false
            throw error
        }
    }
    
    
    /// Gets the latest draw information as a formatted string
    public var latestDrawSummary: String {
        guard !draws.isEmpty, !stars.isEmpty, !drawDates.isEmpty else {
            return "No draw data available"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let dateString = dateFormatter.string(from: drawDates[0])
        let numbersString = draws[0].map { String($0) }.joined(separator: ", ")
        let starsString = stars[0].map { String($0) }.joined(separator: ", ")
        
        return """
            Date: \(dateString)
            Numbers: \(numbersString)
            Stars: \(starsString)
            """
    }
    
    /// Returns a summary of the data store contents
    public var dataSummary: String {
            """
            Total draws: \(draws.count)
            Date range: \(formatDateRange())
            Historical records: \(parsingStats.historicalRows)
            Current records: \(parsingStats.currentRows)
            """
    }
    
    // MARK: - Private Helpers
    
    /// Formats the date range of available data
    private func formatDateRange() -> String {
        guard !drawDates.isEmpty else { return "None" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        if let oldest = drawDates.last, let newest = drawDates.first {
            return "\(dateFormatter.string(from: oldest)) to \(dateFormatter.string(from: newest))"
        }
        
        return "Unknown"
    }
    
    /// Generates a reduced draws array from the draws array,  limited to the draws until all numbers have been drawn once.
    private func generateReducedDraws(draws: [[Int]]) -> [[Int]] {
        var reducedDraws: [[Int]] = []
        var allNumbersDrawn = Array(repeating: 0, count: AppConfig.Game.maxNumberValue + 1)
        var numberCount: Int = 0
        
        for row in 0..<draws.count {
            var shouldAddRow = false
            for column in 0..<draws[row].count {
                let number = draws[row][column]
                if allNumbersDrawn[number] == 0 {
                    allNumbersDrawn[number] = number
                    numberCount += 1
                    shouldAddRow = true
                }
            }
            
            if shouldAddRow {
                reducedDraws.append(draws[row])
            }
            
            // Break the loop if we've found all numbers
            if numberCount >= AppConfig.Game.maxNumberValue {
                break
            }
        }
        
        /*
        // debug
        print("reducedDraws.count: \(reducedDraws.count)")
        print("reducedDraws: \(reducedDraws)")
        var numbers:[Int] = []
        for i in 0..<reducedDraws.count {
            for j in 0..<reducedDraws[i].count {
                numbers.append(reducedDraws[i][j])
            }
        }
        print("numbers: \(numbers.sorted())")
        // end of debug
        */
        
        return reducedDraws
    }
}

// Add this method to your DataStoreBuilder class

extension DataStoreBuilder {
    /// Print diagnostic information about the current state of data
    public func printDiagnostics() {
        print("📊 DataStoreBuilder Diagnostics:")
        print("- Raw draws count: \(draws.count)")
        print("- Sorted draws count: \(sortedDraws.count)")
        print("- Stars count: \(stars.count)")
        print("- Dates count: \(drawDates.count)")
        
        // Check if the first few entries in sortedDraws exist
        if !sortedDraws.isEmpty {
            print("- First sorted draw: \(sortedDraws[0])")
            if sortedDraws.count > 1 {
                print("- Second sorted draw: \(sortedDraws[1])")
            }
        } else {
            print("- sortedDraws is empty!")
            
            // Check if draws has data but sortedDraws doesn't
            if !draws.isEmpty {
                print("- WARNING: draws has \(draws.count) items but sortedDraws is empty")
                print("- First raw draw: \(draws[0])")
            }
        }
        
        // Check loading state
        print("- isLoading: \(isLoading)")
        print("- hasError: \(hasError)")
        if hasError {
            print("- errorMessage: \(errorMessage)")
        }
    }
}
