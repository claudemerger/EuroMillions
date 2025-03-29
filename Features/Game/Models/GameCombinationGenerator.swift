//
//  GameCombinationGenerator.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//

import Foundation


// MARK: - EuroMillions Combination Generator
/// Generates complete EuroMillions combinations using drawing algorithms
struct EuroMillionsCombinationGenerator {
    // Drawing algorithms
    private let numberDrawingAlgorithm: NumberDrawingAlgorithm
    private let starDrawingAlgorithm: StarDrawingAlgorithm
    
    init(numberDrawingAlgorithm: NumberDrawingAlgorithm = NumberDrawingAlgorithm(),
         starDrawingAlgorithm: StarDrawingAlgorithm = StarDrawingAlgorithm()) {
        self.numberDrawingAlgorithm = numberDrawingAlgorithm
        self.starDrawingAlgorithm = starDrawingAlgorithm
    }
    
    /// Generate a complete EuroMillions combination using default parameters
    /// - Returns: A valid EuroMillionsCombination
    func generateCombination() throws -> EuroMillionsCombination {
        // Generate numbers using the default list (1-50)
        let numbersList = Array(1...AppConfig.Game.maxNumberValue)
        let numbers = try numberDrawingAlgorithm.generateDraw(
            list: numbersList,
            count: AppConfig.Game.drawSize
        )
        
        // Generate stars using the default list (1-12)
        let starsList = Array(1...AppConfig.Game.maxStarValue)
        let stars = try starDrawingAlgorithm.generateDraw(
            list: starsList,
            count: AppConfig.Game.starsSize
        )
        
        // Create and return the combination
        return EuroMillionsCombination(
            id: UUID(),
            ballNumbers: numbers,
            starNumbers: stars,
            creationDate: Date(),
            generationStrategy: "StandardRandom"
  
        )
    }
    
    /// Generate a complete EuroMillions combination using custom number and star lists
    /// - Parameters:
    ///   - numbersList: List of numbers to draw from
    ///   - starsList: List of stars to draw from
    /// - Returns: A valid EuroMillionsCombination
    func generateCombination(
        numbersList: [Int],
        starsList: [Int]
    ) throws -> EuroMillionsCombination {
        // Generate numbers from the provided list
        let numbers = try numberDrawingAlgorithm.generateDraw(
            list: numbersList,
            count: AppConfig.Game.drawSize
        )
        
        // Generate stars from the provided list
        let stars = try starDrawingAlgorithm.generateDraw(
            list: starsList,
            count: AppConfig.Game.starsSize
        )
        
        // Create and return the combination
        return EuroMillionsCombination(
            id: UUID(),
            ballNumbers: numbers,
            starNumbers: stars,
            creationDate: Date(),
            generationStrategy: "Custom"
        )
    }
    
    /// Generate multiple EuroMillions combinations
    /// - Parameter count: Number of combinations to generate
    /// - Returns: Array of valid EuroMillionsCombinations
    func generateMultipleCombinations(count: Int) throws -> [EuroMillionsCombination] {
        var combinations: [EuroMillionsCombination] = []
        combinations.reserveCapacity(count)
        
        for _ in 0..<count {
            let combination = try generateCombination()
            combinations.append(combination)
        }
        
        return combinations
    }
}
