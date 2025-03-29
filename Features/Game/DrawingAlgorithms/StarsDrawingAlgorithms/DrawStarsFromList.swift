//
//  DrawStarsFromList.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 20/03/2025.
//


import Foundation


// MARK: - Draw Stars from a list of numbers

/// Handles the random draw of 2 numbers from a list of stars
struct StarDrawingAlgorithm: DrawingAlgorithmFromList {
    var name: String { "Tirage depuis une liste" }
    var description: String { "Tirage aléatoire depuis une liste de numéros" }
    
    /// This function generates a 2 numbers draw from a list of stars
    /// - Parameter list: the drawing list
    /// - Throws:
    /// - Returns: a 2 numbers draw
    func generateDraw(list: [Int], count: Int = 2) throws -> [Int] {
        //print(name)
        //print(description)
        var availableStars = list
        var drawnStars: [Int] = []
        drawnStars.reserveCapacity(count)
        
        for _ in 0..<count {
            let randomIndex = Int.random(in: 0..<availableStars.count)
            drawnStars.append(availableStars.remove(at: randomIndex))
        }
        
        return drawnStars.sorted()
    }
    
    // For stars (1-12)
    static func defaultStarsList() -> [Int] {
        return Array(1...12)
    }
}

