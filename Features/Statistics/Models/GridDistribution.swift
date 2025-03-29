//
//  GridDistribution.swift
//
//  Created by Claude sur iCloud on 09/03/2025.
//
//  This file defines the core logic for analyzing number distributions
//  across different grid configurations (10x5, and 5x10).

import Foundation


// MARK: -
/// Handles the analysis of lottery number distributions across different grid configurations
struct GridConfiguration {
    /// Represents possible patterns of number distributions in rows or columns
    /// Each pattern describes how 5 numbers can be distributed (e.g., "3-2" means 3 numbers in one line, 2 in another)
    enum Pattern: String, CaseIterable {
        case five = "5"            // All 5 numbers in one line
        case fourOne = "4-1"       // 4 numbers in one line, 1 in another
        case threeTwo = "3-2"      // 3 numbers in one line, 2 in another
        case threeOneOne = "3-1-1" // 3 numbers in one line, 1 in each of two others
        case twoTwoOne = "2-2-1"   // 2 numbers in each of two lines, 1 in another
        case twoOneOneOne = "2-1-1-1" // 2 numbers in one line, 1 in each of three others
        case oneOneOneOneOne = "1-1-1-1-1" // 1 number in each of five lines
        case invalid = "invalid"
    }
    
    /// Defines different grid layouts for analyzing number distributions
    enum GridType: Int, CaseIterable, Identifiable {
        case grid10x5 // Alternative 10x5 grid layout
        case grid5x10 // Alternative 5x10 grid layout
        
        var id: Int { self.rawValue }
        
        /// Number of rows in each grid type
        var rows: Int {
            switch self {
            case .grid10x5: return 10   // 10 rows x 5 columns grid
            case .grid5x10: return 5    // 5 rows x 10 columns grid
            }
        }
        
        /// Number of columns in each grid type
        var cols: Int {
            switch self {
            case .grid10x5: return 5    // 10 rows x 5 columns grid
            case .grid5x10: return 10   // 5 rows x 10 columns grid
            }
        }
        
        /// Calculates the row and column position for a given number in the grid
        /// - Parameter number: The ball number (1-50)
        /// - Returns: Tuple containing (row, column) coordinates
        func positionFor(_ number: Int) -> (row: Int, col: Int) {
            switch self {
            case .grid10x5:
                return ((number - 1) % 10, (number - 1) / 10)
            case .grid5x10:
                return ((number - 1) % 5, (number - 1) / 5)
            }
        }
    }
    
    /// Determines the distribution pattern from an array of counts
    /// - Parameter counts: Array containing the number of occurrences in each line
    /// - Returns: The matching Pattern enum case
    static func identifyPattern(_ counts: [Int]) -> Pattern {
        let sortedCounts = counts.filter { $0 > 0 }.sorted(by: >)
        
        switch sortedCounts {
        case let counts where counts == [5]: return .five
        case let counts where counts == [4, 1]: return .fourOne
        case let counts where counts == [3, 2]: return .threeTwo
        case let counts where counts == [3, 1, 1]: return .threeOneOne
        case let counts where counts == [2, 2, 1]: return .twoTwoOne
        case let counts where counts == [2, 1, 1, 1]: return .twoOneOneOne
        case let counts where counts == [1, 1, 1, 1, 1]: return .oneOneOneOneOne
        default: return .invalid
        }
    }
    
    /// Analyzes draws to determine distribution patterns across rows and columns
    /// - Parameters:
    ///   - draws: Array of lottery draws to analyze
    ///   - gridType: The grid configuration to use for analysis
    /// - Returns: Tuple containing pattern counts for both rows and columns
    static func analyzeGrid(draws: [[Int]], gridType: GridType) -> (rows: [Pattern: Int], cols: [Pattern: Int]) {
        // Initialize counters for all possible patterns
        var rowPatternCounts: [Pattern: Int] = Dictionary(uniqueKeysWithValues: Pattern.allCases.map { ($0, 0) })
        var colPatternCounts: [Pattern: Int] = Dictionary(uniqueKeysWithValues: Pattern.allCases.map { ($0, 0) })
        
        for draw in draws {
            var rowCounts = Array(repeating: 0, count: gridType.rows)
            var colCounts = Array(repeating: 0, count: gridType.cols)
            
            // Count numbers in each row and column
            for number in draw {
                let position = gridType.positionFor(number)
                rowCounts[position.row] += 1
                colCounts[position.col] += 1
            }
            
            // Identify patterns and update counts
            let rowPattern = identifyPattern(rowCounts)
            let colPattern = identifyPattern(colCounts)
            rowPatternCounts[rowPattern, default: 0] += 1
            colPatternCounts[colPattern, default: 0] += 1
        }
        
        return (rowPatternCounts, colPatternCounts)
    }
}
