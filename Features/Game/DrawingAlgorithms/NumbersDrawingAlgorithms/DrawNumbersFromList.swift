//
//  DrawNumbersFromList.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 20/03/2025.
//

import Foundation

// MARK: - Draw numbers from a list of numbers (Optimized)
/// Handles the random draw of 5 numbers from a list of numbers
struct NumberDrawingAlgorithm: DrawingAlgorithmFromList {
    
    var name: String { "Tirage depuis une liste" }
    var description: String { "Tirage aléatoire depuis une liste de numéros" }
    
    // Flag to control verbose logging
    private let verboseLogging: Bool
    
    init(verboseLogging: Bool = true) {
        self.verboseLogging = verboseLogging
    }
    
    
    // MARK: - Functions
    
    /// This function generates a 5 numbers draw from a list of numbers
    /// - Parameters:
    ///   - list: the drawing list
    ///   - count: number of numbers to draw (default: 5)
    /// - Throws: Error if the list is too small for the requested count
    /// - Returns: a sorted array of drawn numbers
    ///
    func generateDraw(list: [Int], count: Int = 5) throws -> [Int] {
        
        if verboseLogging {
            print(name)
            print(description)
            print("Liste of numbers: \(list)")
            print("Nombre de N° dans la liste: \(list.count)")
        }
        
        // Validate input
        guard list.count >= count else {
            throw DrawingError.insufficientNumbers(available: list.count, requested: count)
        }
        
        // Create a local copy of the list to avoid multiple array copies in the loop
        var availableNumbers = list
        var drawnNumbers = [Int]()
        drawnNumbers.reserveCapacity(count)
        
        // More efficient algorithm for small count values relative to list size
        for _ in 0..<count {
            let randomIndex = Int.random(in: 0..<availableNumbers.count)
            drawnNumbers.append(availableNumbers.remove(at: randomIndex))
        }
        
        return drawnNumbers.sorted()
    }
    
    // For main numbers (1-50)
    static func defaultNumbersList() -> [Int] {
        return Array(1...50)
    }
}


// Add a custom error type for drawing operations

enum DrawingError: Error {
    case insufficientNumbers(available: Int, requested: Int)
    
    var localizedDescription: String {
        switch self {
        case .insufficientNumbers(let available, let requested):
            return "Cannot draw \(requested) numbers from a list with only \(available) numbers"
        }
    }
}


/*
// MARK: - Draw numbers from a list of numbers
/// Handles the random draw of 5 numbers from a list of numbers
struct NumberDrawingAlgorithm: DrawingAlgorithmFromList {
    
    var name: String { "Tirage depuis une liste" }
    var description: String { "Tirage aléatoire depuis une liste de numéros" }
    
    /// This function generates a 5 numbers draw from a list of numbers
    /// - Parameter list: the drawing list
    /// - Throws:
    /// - Returns: a 5 numbers draw
    func generateDraw(list: [Int], count: Int = 5) throws -> [Int] {
        
        print(name)
        print(description)
        print("Liste of numbers: \(list)")
        print("Nombre de N° dans la liste: \(list.count)")
        
        var availableNumbers = list
        var drawnNumbers: [Int] = []
        drawnNumbers.reserveCapacity(count)
        
        for _ in 0..<count {
            let randomIndex = Int.random(in: 0..<availableNumbers.count)
            drawnNumbers.append(availableNumbers.remove(at: randomIndex))
        }
        
        return drawnNumbers.sorted()
    }
    
    // For main numbers (1-50)
    static func defaultNumbersList() -> [Int] {
        return Array(1...50)
    }
*/
    



