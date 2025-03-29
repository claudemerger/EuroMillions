//
//  WeightAnalysis.swift
//
//  Created by Claude sur iCloud on 20/12/2024.
//

import Foundation

/// `GenerateWeightTable` provides utilities for analyzing the frequency of lottery numbers
/// in future draws based on historical data.
///
/// The main functionality calculates "weight" - how many times each drawn number appears
/// within a specified distance (number of positions) in future draws. This can help identify
/// patterns in the lottery number distribution over time.
///

// MARK: - Structure

/// Errors that can occur during weight analysis
enum WeightDistributionError: Error {
    case emptyTable
    case emptyFirstRow
    case invalidNumberRange(Int)
}

struct GenerateWeightTable {

    
    // MARK: - Public Interface
    /// Calculates the occurrence frequency of lottery numbers within a specified future distance.
    ///
    /// - Parameters:
    ///   - table: A 2D array of historical lottery draws, where each inner array represents one draw
    ///   - distance: The number of positions ahead to check for occurrences of each number
    ///
    /// - Throws:
    ///   - `WeightDistributionError.emptyTable` if the input table has no rows
    ///   - `WeightDistributionError.emptyFirstRow` if the first row is empty
    ///   - `WeightDistributionError.invalidNumberRange` if the distance parameter is invalid
    ///
    /// - Returns: A 2D array where each element represents the number of times a drawn number
    ///            appears within the specified distance in future positions
    ///
    /// The function analyzes each draw and counts how many times each number in that draw
    /// appears in subsequent positions within the specified distance. This provides insight
    /// into whether certain numbers tend to reappear within specific timeframes.
    ///
    static func calculateNumberWeight(table: [[Int]], distance: Int) throws -> [[Int]] {
        guard !table.isEmpty else {
            throw WeightDistributionError.emptyTable
        }
        guard !table[0].isEmpty else {
            throw WeightDistributionError.emptyFirstRow
        }
        guard distance > 0 else {
            throw WeightDistributionError.invalidNumberRange(distance)
        }
        
        let numbersPerDraw = table[0].count
        let totalPositions = table.count * numbersPerDraw
        var occurrenceTable = [[Int]]()
        occurrenceTable.reserveCapacity(table.count)
        
        // Main processing loop with optimizations
        for i in 0..<table.count {
            var numberFrequency: [Int: Int] = [:]
            let startPos = i * numbersPerDraw
            
            // Look ahead optimization: break early if we're past possible range
            let maxLookAhead = min(distance, totalPositions - startPos - 1)
            
            // Process future positions - start AFTER the current numbers
            let currentLastPos = startPos + numbersPerDraw - 1
            for offset in 1...maxLookAhead {
                let futurePosition = currentLastPos + offset
                if futurePosition < totalPositions {
                    let drawIndex = futurePosition / numbersPerDraw
                    let positionInDraw = futurePosition % numbersPerDraw
                    
                    if drawIndex < table.count {
                        let number = table[drawIndex][positionInDraw]
                        numberFrequency[number, default: 0] += 1
                    }
                }
            }
            
            // Record frequencies for numbers in current draw
            var currentOccurrences: [Int] = []
            for number in table[i] {
                let count = numberFrequency[number] ?? 0
                currentOccurrences.append(count)
            }
            occurrenceTable.append(currentOccurrences)
        }
        
        return occurrenceTable
    }
}
// Extended error handling
extension WeightDistributionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyTable:
            return "The draw table is empty"
        case .emptyFirstRow:
            return "The first row of the draw table is empty"
        case .invalidNumberRange(let value):
            return "Invalid distance value: \(value). Must be greater than 0"
        }
    }
}
 
/// Comments
/// 1. The WeightAnalysisError enum defines three possible error cases that can occur in your weight analysis:
/// emptyTable: when the input table has no rows
/// emptyFirstRow: when the first row has no numbers
/// invalidNumberRange(Int): when the distance parameter is invalid (the Int parameter lets you include the actual invalid value)
///
/// 2. By conforming to Swift's LocalizedError protocol through the extension, you're adding user-friendly error messages for each case. This means:
/// When you catch one of these errors, you can access its localizedDescription property to get a readable message
/// These messages will be what users see if the error bubbles up to the UI
