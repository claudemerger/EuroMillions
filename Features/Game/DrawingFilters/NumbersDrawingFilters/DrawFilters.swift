//
//  DrawFilters.swift
//
//
//  Created by Claude sur iCloud on 20/03/2025
//

import Foundation

// MARK: - Structure DrawFilters
/// Struct containing all validation filters for lottery number combinations
/// Each filter represents a specific rule or constraint that a valid game must satisfy
struct DrawFilters {
    
    // MARK: - Filter Configuration
        /// Structure to hold filter states
        struct FilterConfig {
            let noDoublon: Bool             // Test 1 & 2
            let isOdd: Bool                 // Test 3
            let g10x5EvenlySplitted: Bool   // Test 5
            let g5x10EvenlySplitted: Bool   // Test 6
            let noSeries: Bool              // Test 7
        }
    
    // MARK: - Main Validation
    
    /// Primary validation method that applies all filters to a game
    /// - Parameters:
    ///   - game: Array of 5 integers representing the lottery numbers
    ///   - gameTable: Array of previously generated valid games in current session
    ///   - historicalDrawTable: Array of historical lottery draws
    ///   - config: FilterConfig containing the state of each filter toggle
    /// - Returns: Boolean indicating if the game passes all validation filters
    
    static func checkGame(
            game: [Int],
            gameTable: [[Int]],
            historicalDrawTable: [[Int]],
            config: FilterConfig
        ) -> Bool {
            
            // Using early return pattern for efficiency
            if validityTest1(game: game, table: gameTable) == false { return false }
            
            // Only apply filters that are enabled
            if config.noDoublon {
                //if validityTest1(game: game, table: gameTable) == false { return false }
                if validityTest2b(game: game, table: historicalDrawTable) == false { return false }
            }
            
            if config.isOdd {
                if validityTest3(game: game) == false { return false }
            }
                        
            if config.g10x5EvenlySplitted {
                if validityTest5(game: game) == false { return false }
            }
            
            if config.g5x10EvenlySplitted {
                if validityTest6(game: game) == false { return false }
            }
            
            if config.noSeries {
                if validityTest7(game: game) == false { return false }
            }
            
            return true
        }
    
    /*
    static func checkGame(game: [Int], gameTable: [[Int]], historicalDrawTable: [[Int]]) -> Bool {
        // Using early return pattern for efficiency
        if validityTest1(game: game, table: gameTable) == false { return false }
        if validityTest2(game: game, table: historicalDrawTable) == false { return false }
        if validityTest3(game: game) == false { return false }
        if validityTest4(game: game) == false { return false }
        if validityTest5(game: game) == false { return false }
        if validityTest6(game: game) == false { return false }
        if validityTest7(game: game) == false { return false }
        
        return true
    }
    */
    
    // MARK: - Individual Filters
    
    /// Test 1: Duplicate Prevention
    /// Ensures the game hasn't been generated before in the current session
    static func validityTest1(game: [Int], table: [[Int]]) -> Bool {
        guard table.count != 0 else { return true }
        return !isDuplicateGame(game, in: table)
    }
    
     
    /// Test 3: Even/Odd Distribution
    /// Ensures balanced distribution of even and odd numbers
    /// Valid games must have 1-4 even numbers (consequently 1-4 odd numbers)
    static func validityTest3(game: [Int]) -> Bool {
        let evenCount = game.lazy.filter { $0 % 2 == 0 }.count
        return evenCount <= 4 && evenCount >= 1
    }
    
    /// Test 5: 10x5 Grid Distribution (columns: 1-10, 11-20, 21-30, 31-40, 41-50)
    /// Valid row patterns: 1-1-1-1-1, 2-1-1-1
    /// Valid column patterns: 2-1-1-1, 2-2-1, 3-1-1
    static func validityTest5(game: [Int]) -> Bool {
        var rowCounts = Array(repeating: 0, count: GridConfiguration.GridType.grid10x5.rows)
        var colCounts = Array(repeating: 0, count: GridConfiguration.GridType.grid10x5.cols)
        
        // Count numbers in each row and column using GridConfiguration
        for number in game {
            let position = GridConfiguration.GridType.grid10x5.positionFor(number)
            rowCounts[position.row] += 1
            colCounts[position.col] += 1
        }
        
        // Identify patterns using GridConfiguration
        let rowPattern = GridConfiguration.identifyPattern(rowCounts)
        let colPattern = GridConfiguration.identifyPattern(colCounts)
        
        // Check if patterns match allowed configurations
        let validRowPatterns: Set<GridConfiguration.Pattern> = [
            .oneOneOneOneOne,
            .twoOneOneOne
        ]
        
        let validColPatterns: Set<GridConfiguration.Pattern> = [
            .twoOneOneOne,
            .twoTwoOne,
            .threeOneOne
        ]
        
        return validRowPatterns.contains(rowPattern) && validColPatterns.contains(colPattern)
    }

    /// Test 6: 5x10 Grid Distribution
    /// Valid row patterns: 2-1-1-1, 2-2-1, 3-1-1
    /// Valid column patterns: 1-1-1-1-1, 2-1-1-1
    static func validityTest6(game: [Int]) -> Bool {
        var rowCounts = Array(repeating: 0, count: GridConfiguration.GridType.grid5x10.rows)
        var colCounts = Array(repeating: 0, count: GridConfiguration.GridType.grid5x10.cols)
        
        // Count numbers in each row and column using GridConfiguration
        for number in game {
            let position = GridConfiguration.GridType.grid5x10.positionFor(number)
            rowCounts[position.row] += 1
            colCounts[position.col] += 1
        }
        
        // Identify patterns using GridConfiguration
        let rowPattern = GridConfiguration.identifyPattern(rowCounts)
        let colPattern = GridConfiguration.identifyPattern(colCounts)
        
        // Check if patterns match allowed configurations
        let validRowPatterns: Set<GridConfiguration.Pattern> = [
            .twoOneOneOne,
            .twoTwoOne,
            .threeOneOne
        ]
        
        let validColPatterns: Set<GridConfiguration.Pattern> = [
            .oneOneOneOneOne,
            .twoOneOneOne
        ]
        
        return validRowPatterns.contains(rowPattern) && validColPatterns.contains(colPattern)
    }
    
    /// Test 7: Consecutive Numbers
    /// Prevents more than 2 consecutive numbers in a game
    /// Example: [1,2,3] would be invalid, but [1,2,4] is valid
    static func validityTest7(game: [Int]) -> Bool {
        let sortedGame = game.sorted()
        
        for i in 0...(sortedGame.count - 3) {
            if sortedGame[i + 2] == sortedGame[i] + 2 &&
                sortedGame[i + 1] == sortedGame[i] + 1 {
                return false
            }
        }
        return true
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a game is a duplicate of any game in the results array
    /// - Parameters:
    ///   - game: The game to check
    ///   - results: Array of existing games to check against
    /// - Returns: True if the game is a duplicate
    static func isDuplicateGame(_ game: [Int], in results: [[Int]]) -> Bool {
        results.contains(game)
    }
    
    /// Compares a game against a table of games and returns match counts
    /// Implementation details in ArrayFunctions.swift
    static func compareGameToTable(_ game: [Int], _ table: [[Int]]) -> [Int] {
        return compareArrayToTable(game, table)
    }
}
