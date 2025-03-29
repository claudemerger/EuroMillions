//
//  GenerateDistanceTable.swift
//
//  Created by Claude sur iCloud on 03/03/2025.
//

import Foundation

struct GenerateDistanceTable {
    
    /// Errors that can occur during distance analysis
    enum DistanceAnalysisError: Error {
        case emptyTable
        case emptyFirstRow
        case invalidNumberRange(Int)
    }
    
    // MARK: - AppConfig
    
    private enum AppConfig {
        static let minNumber = 1
        //static let maxNumber = 49     // Loto version
        static let maxNumber = 50       // EuroMillions version
    }
    
    // MARK: - Private Methods
    
    /// Calculates the distance between identical numbers in the draw table
    /// - Parameter table: The source table containing historical draws
    /// - Throws: DistanceAnalysisError if the input data is invalid
    /// - Returns: A 2D array containing distances between identical numbers
    
    
    static func calculateNumberDistance(table: [[Int]]) throws -> [[Int]] {
        // Input validation
        guard !table.isEmpty else {
            throw DistanceAnalysisError.emptyTable
        }
        guard !table[0].isEmpty else {
            throw DistanceAnalysisError.emptyFirstRow
        }
        
        let numberOfRows = table.count
        let numberOfColumns = table[0].count
        
        // Initialize number tracking dictionary
        var numberDictionary = initializeNumberDictionary()
        var distanceTable = Array(repeating: Array(repeating: 0, count: numberOfColumns), count: numberOfRows)
        var numberIndex = 1
        
        // Process the table from right to left, top to bottom
        for row in 0..<numberOfRows {
            for column in (0..<numberOfColumns).reversed() {
                let currentNumber = table[row][column]
                // Validate number range
                guard (AppConfig.minNumber...AppConfig.maxNumber).contains(currentNumber) else {
                    throw DistanceAnalysisError.invalidNumberRange(currentNumber)
                }
                try updateDistanceTable(
                    currentNumber: currentNumber,
                    numberIndex: numberIndex,
                    row: row,
                    column: column,
                    numberDictionary: &numberDictionary,
                    distanceTable: &distanceTable
                )
                numberIndex += 1
            }
        }
        return distanceTable
    }
    
    /// Initializes the dictionary to track number positions and indices
    static private func initializeNumberDictionary() -> [Int: (rowPosition: Int, colPosition: Int, index: Int)] {
        Dictionary(
            uniqueKeysWithValues: (AppConfig.minNumber...AppConfig.maxNumber).map {
                ($0, (rowPosition: 0, colPosition: 0, index: 0))
            }
        )
    }
    
    /// Updates the distance table for a given number
    static private func updateDistanceTable(
        currentNumber: Int,
        numberIndex: Int,
        row: Int,
        column: Int,
        numberDictionary: inout [Int: (rowPosition: Int, colPosition: Int, index: Int)],
        distanceTable: inout [[Int]]
    ) throws {
        guard var numberInfo = numberDictionary[currentNumber] else {
            throw DistanceAnalysisError.invalidNumberRange(currentNumber)
        }
        
        if numberInfo.index != 0 {
            distanceTable[numberInfo.rowPosition][numberInfo.colPosition] = numberIndex - numberInfo.index
        }
        
        numberInfo = (rowPosition: row, colPosition: column, index: numberIndex)
        numberDictionary[currentNumber] = numberInfo
    }
}
