//
//  DrawingAlgorithmFromComputedList.swift
//  EuroMillions
//
//  Created on 21/03/2025.
//

import Foundation

// MARK: - Draw from a computed list of numbers, based on historical patterns
/// Handles the draw of 5 numbers from a computed list of numbers for each column.
/// For each column, the computed list will be generated with all the numbers drawn following the last drawn number.
/// A drawing algorithm that generates numbers based on historical patterns in column sequences
/// while ensuring viable number selection through statistical analysis and smart filtering.
///
/// This algorithm works by:
/// 1. Analyzing historical patterns of numbers that appear before each reference number
/// 2. Using statistical analysis to ensure selected numbers leave viable options for subsequent columns
/// 3. Maintaining ascending order across columns while preserving randomness`
///
struct ColumnDrawingBasedOnNumberDrawHistoryAlgorithm: DrawingAlgorithmFromTable {
    
    /// Historical draw data used for pattern analysis
    private let historicalDraws: [[Int]]
    /// Creates a new instance of the drawing algorithm
    /// - Parameter historicalDraws: Array of previous draw results to analyze for patterns
    init(historicalDraws: [[Int]]) {
        self.historicalDraws = historicalDraws
    }
    /// Algorithm identifier shown in the user interface
    var name: String { "Tirage par colonnes" }
    /// Description of the algorithm's approach shown in the user interface
    var description: String { "Tirage Aléatoire à partir l'historique des N° tirés à la suite du précédent N° de la colonne" }
    

    /// Generates a complete draw of 5 numbers using historical pattern analysis
    /// - Parameters:
    ///   - table: Matrix of historical draws, sorted in ascending order
    ///   - count: Number of numbers to draw (default is 5)
    /// - Returns: Array of drawn numbers in ascending order
    /// - Throws: GameError if unable to generate valid numbers
    ///
    func generateDraw(table: [[Int]], count: Int = 5) throws -> [Int] {
        
        print(name)
        print(description)
        
        // Validate input table dimensions
        guard !table.isEmpty else {
            throw GameError.invalidNumberRange
        }
        
        guard table[0].count >= 5 else {
            throw GameError.invalidNumberRange
        }
        
        var drawnNumbers: [Int] = []
        
        // Generate first number without previous constraints
        let firstNumber = try smartDrawFromColumn(table: table, columnIndex: 0, previousDraw: nil)
        drawnNumbers.append(firstNumber)
        
        // Generate remaining numbers with progressive constraints
        for columnIndex in 1...4 {
            let nextNumber = try smartDrawFromColumn(
                table: table,
                columnIndex: columnIndex,
                previousDraw: drawnNumbers[columnIndex - 1]
            )
            drawnNumbers.append(nextNumber)
        }
        
        return drawnNumbers
    }
    
    /// Performs smart number selection for a specific column considering both historical patterns
    /// and viability for subsequent columns
    /// - Parameters:
    ///   - table: Matrix of historical draws
    ///   - columnIndex: Current column being processed (0-4)
    ///   - previousDraw: Number drawn from previous column (nil for first column)
    /// - Returns: Selected number for the current column
    /// - Throws: GameError if no valid numbers are available
    ///
    private func smartDrawFromColumn(table: [[Int]], columnIndex: Int, previousDraw: Int?) throws -> Int {
        
        // Get historical patterns for current column
        let currentColumn = table.map { $0[columnIndex] }
        let historyList = buildListFromPrecedingNumber(from: currentColumn)
        
        // Apply ascending order constraint if not first column
        let availableNumbers = previousDraw != nil ?
            historyList.filter { $0 > previousDraw! } :
            historyList
        
        // For all columns except the last, apply smart selection considering next column
        if columnIndex < 4 {
            let nextColumn = table.map { $0[columnIndex + 1] }
            let nextColumnMax = nextColumn.max() ?? 49
            let nextColumnMedian = nextColumn.sorted()[nextColumn.count / 2]
            
            // Set upper limit to ensure viability for next column
            let upperLimit = min(
                nextColumnMedian,
                Int(Double(nextColumnMax) * 0.8)  // Stay within 80% of maximum
            )
            
            // Score each number based on how many options it leaves for next column
            let scoredNumbers = availableNumbers.compactMap { num -> (number: Int, score: Int)? in
                guard num < upperLimit else { return nil }
                
                let availableNext = nextColumn.filter { $0 > num }.count
                return (num, availableNext)
            }
            
            // Select from top 70% of candidates to balance viability and randomness
            let sortedNumbers = scoredNumbers.sorted { $0.score > $1.score }
            let candidateCount = max(1, Int(Double(sortedNumbers.count) * 0.7))
            let topCandidates = Array(sortedNumbers.prefix(candidateCount))
            
            guard !topCandidates.isEmpty else {
                throw GameError.invalidNumberRange
            }
            
            return topCandidates.randomElement()!.number
            
        } else {
            // For last column, only ensure we have valid numbers
            guard !availableNumbers.isEmpty else {
                throw GameError.invalidNumberRange
            }
            
            return availableNumbers.randomElement()!
        }
    }
    
    /// Analyzes a column to build a list of numbers that historically appear
    /// before each occurrence of the reference number
    /// - Parameter list: Array of numbers from a specific column
    /// - Returns: Array of numbers that historically precede the reference number
    private func buildListFromPrecedingNumber(from list: [Int]) -> [Int] {
        let referenceNumber = list[0]  // First number becomes reference
        var historyList: [Int] = []
        
        // Find all numbers that appear before the reference number in the sequence
        for listIndex in 1..<list.count {
            if list[listIndex] == referenceNumber {
                historyList.append(list[listIndex - 1])
            }
        }
        
        return historyList
    }
}

