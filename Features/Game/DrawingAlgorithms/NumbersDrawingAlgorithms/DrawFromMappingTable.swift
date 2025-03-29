//
//  DrawFromMappingTable.swift
//  EuroMillions
//
//  Created on 21/03/2025.
//

import Foundation

// MARK: - Draw using mapping table analysis
/// Handles the draw of numbers based on mapping table analysis (distance and frequency)
struct MappingTableBasedDrawingAlgorithm: DrawingAlgorithmFromTable {
    /// Historical draw data used for pattern analysis
    private let historicalDraws: [[Int]]
    /// Mapping table from DataStore
    private let mappingTable: [[Int]]
    /// Maximum allowed distance for number selection
    private let maxDistance: Int
    
    var name: String { "Tirage basé sur le mapping" }
    var description: String { "Tirage depuis une liste filtrée selon la distance et la fréquence d'apparition" }
    
    /// Creates a new instance of the mapping table drawing algorithm
    /// - Parameters:
    ///   - historicalDraws: Array of previous draw results
    ///   - mappingTable: The mapping table from DataStore
    ///   - maxDistance: Maximum allowed distance for number selection
    init(historicalDraws: [[Int]], mappingTable: [[Int]], maxDistance: Int = 5) {
        self.historicalDraws = historicalDraws
        self.mappingTable = mappingTable
        self.maxDistance = maxDistance
        //print("Mapping Table: \(mappingTable)")
    }

    /// Generates a draw based on mapping table analysis
    /// - Parameters:
    ///   - table: Matrix of historical draws (required by protocol but we use mappingTable instead)
    ///   - count: Number of numbers to draw (default 5)
    /// - Returns: Array of drawn numbers in ascending order
    /// - Throws: GameError if unable to generate valid numbers
    func generateDraw(table: [[Int]], count: Int = 5) throws -> [Int] {
        
        print(name)
        print(description)
        
        // Get filtered list of preferred numbers
        let preferredNumbers = getPreferredNumbers()
        
        //print("preferred Numbers list:  \(preferredNumbers)")
        
        guard preferredNumbers.count >= count else {
            throw GameError.invalidNumberRange
        }
        
        // Use ListDrawingAlgorithm to draw from filtered list
        let listAlgorithm = NumberDrawingAlgorithm()
        return try listAlgorithm.generateDraw(list: preferredNumbers, count: count)
    }
    
    /// Filters numbers based on mapping table criteria
    /// - Returns: Array of numbers meeting the distance and frequency criteria
    private func getPreferredNumbers() -> [Int] {
        var preferredNumbers: [Int] = []
        
        // mappingTable structure:
        // Row 0: numbers (1-49)
        // Row 1: distance
        // Row 2: frequency
        
        //print("Mapping Table: \(mappingTable)")
        
        for i in 0..<mappingTable[0].count {
            let number = mappingTable[0][i]
            let distance = mappingTable[1][i]
            let frequency = mappingTable[2][i]
            
            // Skip if number is 0 (unused in mapping table)
            guard number != 0 else { continue }
            
            // Apply filtering criteria:
            // 1. Distance must be within 5 - 99
            // 2. Frequency must be between 2 and 4
            if distance > 5 && distance <= 100 && frequency > 1 && frequency <= 4 {
                preferredNumbers.append(number)
            }
        }
        
        return preferredNumbers.sorted()
    }
}

// MARK: - Joker drawing algorithm
/// A drawing algorithm that generates joker numbers based on historical patterns
struct JokerNumberDrawingBasedOnHistoryAlgorithm {
    /// Historical joker draw data used for pattern analysis
    private let historicalJokerDraws: [Int]
    
    /// Creates a new instance of the joker drawing algorithm
    /// - Parameter historicalJokerDraws: Array of previous joker draw results to analyze for patterns
    init(historicalJokerDraws: [Int]) {
        self.historicalJokerDraws = historicalJokerDraws
    }
    
    /// Algorithm identifier shown in the user interface
    var name: String { "Tirage du numéro joker" }
    
    /// Description of the algorithm's approach shown in the user interface
    var description: String { "Tirage Aléatoire à partir de l'historique des N° joker" }

    /// Generates a joker number using historical pattern analysis
    /// - Returns: A joker number
    /// - Throws: GameError if unable to generate valid number
    func generateJokerNumber() throws -> Int {
        // Validate we have historical data
        guard !historicalJokerDraws.isEmpty else {
            throw GameError.invalidNumberRange
        }
        
        // Build a frequency map of joker numbers
        var frequencyMap: [Int: Int] = [:]
        for number in historicalJokerDraws {
            frequencyMap[number, default: 0] += 1
        }
        
        // Convert to an array of tuples for weighted selection
        let weightedNumbers = frequencyMap.map { (number: $0.key, weight: $0.value) }
        
        // Calculate total weight for random selection
        let totalWeight = weightedNumbers.reduce(0) { $0 + $1.weight }
        
        // Generate random weight
        var randomWeight = Int.random(in: 0..<totalWeight)
        
        // Select number based on weighted distribution
        for (number, weight) in weightedNumbers {
            if randomWeight < weight {
                return number
            }
            randomWeight -= weight
        }
        
        // Fallback to random from historical numbers if weighted selection fails
        return historicalJokerDraws.randomElement() ??
            Int.random(in: 1...10) // Assuming joker range is 1-10
    }
}

