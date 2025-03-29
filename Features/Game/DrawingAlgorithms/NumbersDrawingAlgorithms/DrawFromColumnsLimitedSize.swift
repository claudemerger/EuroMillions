//
//  DrawFromColumnsLimitedSize.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 21/03/2025.
//

import Foundation

// MARK: - Draw from the reduced, sorted historical draws table
/// Handles the draw of 5 numbers from the reduced, sorted historical draws table.
/// The table is limited to the numbers of draws such as every number is drawn at least one time.
/// A number is drawn in each column of the table. The draw can be considered as weighted depending on occurence of every number.
/// 
struct ColumnSpreadBasedDrawingAlgorithm: DrawingAlgorithmFromTable {
    
    // MARK: - Properties
    
    /// The complete set of historical draws to use as the basis for the algorithm
    private let historicalDraws: [[Int]]
    
    /// Flag to enable detailed logging during the drawing process
    /// When true, will print information about each step of the drawing algorithm
    private let verboseLogging: Bool
    
    // MARK: - Protocol Properties
    
    /// Human-readable name of the algorithm (in French)
    var name: String { "Tirage par colonnes sur un historique réduit" }
    
    /// Brief description of how the algorithm works (in French)
    var description: String { "Tirage Aléatoire d'un numéro par colonne" }
    
    // MARK: - Initialization
    
    /// Initializes the drawing algorithm with the necessary historical data
    /// - Parameters:
    ///   - historicalDraws: Array of previous EuroMillions draws, each as an array of integers
    ///   - verboseLogging: Whether to enable detailed console logging (defaults to false)
    init(historicalDraws: [[Int]], verboseLogging: Bool = false) {
        self.historicalDraws = historicalDraws
        self.verboseLogging = verboseLogging
    }

    // MARK: - Main Drawing Function
    /// This function generates a 5-number draw using a reduced, sorted historical draws table.
    /// This function generates a draw from the sorted historical draws table using this process.
    /// For each column of the table it will build a list of all the numbers from the top of the table until each of the possible numbers of that column has been drawn once.
    /// 1-  Draw from column 0: It will draw one random number from column 0 of the spread list of column 0
    /// 2 - Draw from column 1: it will remove remove all numbers from spread list column 1 lower or equal to the drawn number in column 0,  and draw a number from this list.
    /// 3 - Draw from column 2: it will remove remove all numbers from spread list column 2 lower or equal to the drawn number in column 1,  and draw a number from this list.
    /// 4 - Draw from column 3: it will remove remove all numbers from spread list column 3 lower or equal to the drawn number in column 2,  and draw a number from this list.
    /// 5 - Draw from column 4: it will remove remove all numbers from spread list column 4 lower or equal to the drawn number in column 3,  and draw a number from this list.
    ///
    /// - Parameters:
    ///   - table: Historical draws table, sorted in ascending order
    ///   - count: Number of numbers to draw (default 5)
    /// - Returns: Array of drawn numbers in ascending order
    /// - Throws: GameError if unable to generate valid numbers
    
    func generateDraw(table: [[Int]], count: Int = 5) throws -> [Int] {
        
        // Log algorithm details if verbose logging is enabled
        if verboseLogging {
            print(name)
            print(description)
            print("Table des tirages réduite: \(table)")
        }


        // Validate that the input table exists and has sufficient data
        guard !table.isEmpty else {
            throw GameError.invalidNumberRange
        }
        guard table[0].count >= 5 else {
            throw GameError.invalidNumberRange
        }
        
        // Initialize array to hold the drawn numbers
        var drawnNumbers = [Int]()
        drawnNumbers.reserveCapacity(5) // Optimize memory allocation
        
        
        // Track the most recently drawn number
        var draw = 0
        
        // Step 1: Process the first column (column 0)
        let column0 = table.map { $0[0] }
        guard !column0.isEmpty else {
            throw GameError.invalidNumberRange
        }
        
        // Draw a random number from the first column
        draw = column0.randomElement()!
        drawnNumbers.append(draw)
        
        if verboseLogging {
            print("Column 0 draw: \(draw)")
        }
        
        // Steps 2-5: Process columns 1 through 4
        for index in 1...4 {
            // Extract the current column from the table
            let column = table.map { $0[index] }
            
            // Filter to include only numbers greater than the previously drawn number
            // This ensures the final set will be in ascending order
            let tempList = column.filter { $0 > draw }
            
            // Verify we have at least one valid number to choose from
            guard !tempList.isEmpty else {
                throw GameError.invalidNumberRange
            }
            
            // Draw a random number from the filtered list
            draw = tempList.randomElement()!
            drawnNumbers.append(draw)
            
            // Log the result if verbose logging is enabled
            if verboseLogging {
                print("Column \(index) draw: \(draw)")
            }
        }
        
        // Return the complete set of 5 drawn numbers
        return drawnNumbers
    }
    
    // MARK: - Helper Functions
    
    /// Creates an empty distribution array initialized with zeros
    /// - Parameter maxValue: The highest possible number in the column
    /// - Returns: A 2D array with [number, spread, weight] for each possible number
    private func buildDistributionArray(maxValue: Int) -> [[Int]] {
        return [[Int]](repeating: [Int](repeating: 0, count: 3), count: maxValue + 1)
    }
    
    /// Updates the distribution statistics for a number
    /// - Parameters:
    ///   - distribution: The distribution array to update
    ///   - number: The number being processed
    ///   - index: Current index in the sequence
    ///   - drawnCount: Counter for unique numbers seen
    private func updateDistribution(
        _ distribution: inout [[Int]],
        number: Int,
        index: Int,
        drawnCount: inout Int
    ) {
        distribution[number][0] = number            // Store the number
        
        if distribution[number][1] == 0 {           // First time seeing this number
            distribution[number][1] = index + 1     // Record spread
            distribution[number][2] = 1             // Initialize weight
            drawnCount += 1
        } else {
            distribution[number][2] += 1            // Increment weight
        }
    }
    
    /// Analyzes a column to determine its spread (number of draws until all numbers in that column are drawn)
    private func analyzeColumnSpread(_ column: [Int]) -> (spread: Int, distribution: [[Int]]) {
        var distributionArray = buildDistributionArray(maxValue: column.max()!)
        var drawnNumbersCount = 0
        var listIndex = 0
        let uniqueNumbersCount = Set(column).count
        
        while drawnNumbersCount < uniqueNumbersCount {
            let number = column[listIndex]
            updateDistribution(
                &distributionArray,
                number: number,
                index: listIndex,
                drawnCount: &drawnNumbersCount
            )
            listIndex += 1
        }
        
        return (listIndex, Array(distributionArray.dropFirst()))
    }
    
    /// This function draws a number from the first column using spread analysis
    private func drawFromFirstColumn(_ table: [[Int]]) throws -> Int {
        let column = table.map { $0[0] }
        let (spread, _) = analyzeColumnSpread(column)
        return column[Int.random(in: 0..<spread)]
    }
    
    /// Draws a number from a subsequent column considering the previous draw
    private func drawFromColumn(table: [[Int]], columnIndex: Int, previousDraw: Int) throws -> Int {
        let column = table.map { $0[columnIndex] }
        let (spread, _) = analyzeColumnSpread(column)
        
        let availableNumbers = Array(column[0..<spread]).filter { $0 > previousDraw }
        guard !availableNumbers.isEmpty else {
            throw GameError.invalidNumberRange
        }
        
        return availableNumbers.randomElement()!
    }
}

