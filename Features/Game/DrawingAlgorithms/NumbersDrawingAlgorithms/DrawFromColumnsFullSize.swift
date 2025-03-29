//
//  DrawingAlgorithmFromColumns.swift
//  EuroMillions
//
//  Created on 24/03/2025.
//

import Foundation

// MARK: - Column-Based Drawing Algorithm

/// Handles the drawing of 5 numbers from the complete, sorted historical draws table.
/// This algorithm draws one number from each column of the table, ensuring ascending order.
/// The approach can be considered as history-weighted, as it uses the frequency distribution
/// of numbers within each position (column) of previous draws.
/// 
struct ColumnBasedDrawingAlgorithm: DrawingAlgorithmFromTable {
    // MARK: - Properties
    
    /// The complete set of historical draws to use as the basis for the algorithm
    private let historicalDraws: [[Int]]
    
    /// Flag to enable detailed logging during the drawing process
    /// When true, will print information about each step of the drawing algorithm
    private let verboseLogging: Bool
    
    // MARK: - Protocol Properties
    
    /// Human-readable name of the algorithm (in French)
    var name: String { "Tirage par colonnes sur tout l'historique" }
    
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
    
    // MARK: - Drawing Algorithm Implementation
    
    /// Generates a new 5-number draw using the column-based algorithm.
    ///
    /// The algorithm follows these steps:
    /// 1. Draw from column 0: Select one random number from the first column
    /// 2. Draw from column 1: Remove all numbers from column 1 that are less than or equal to
    ///    the number drawn from column 0, then randomly select from remaining numbers
    /// 3. Draw from column 2: Remove all numbers from column 2 that are less than or equal to
    ///    the number drawn from column 1, then randomly select from remaining numbers
    /// 4. Draw from column 3: Remove all numbers from column 3 that are less than or equal to
    ///    the number drawn from column 2, then randomly select from remaining numbers
    /// 5. Draw from column 4: Remove all numbers from column 4 that are less than or equal to
    ///    the number drawn from column 3, then randomly select from remaining numbers
    ///
    /// This ensures the resulting 5 numbers are in ascending order, following the
    /// EuroMillions drawing rules.
    ///
    /// - Parameters:
    ///   - table: 2D array containing the sorted historical draws table
    ///   - count: Number of numbers to draw (default is 5, the standard for EuroMillions)
    /// - Throws: GameError if there are insufficient numbers in any column or other validation issues
    /// - Returns: An array of 5 integers representing the drawn numbers in ascending order
    
    func generateDraw(table: [[Int]], count: Int = 5) throws -> [Int] {
        
        // Log algorithm details if verbose logging is enabled
        if verboseLogging {
            print(name)
            print(description)
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
}
