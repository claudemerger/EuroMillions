//
//  DrawStats.swift
//
//  Created by Claude sur iCloud on 06/03/2025.
//

import Foundation

/// This function computes the distribution of all the numbers for each column of the sorted historical draws table.
/// - Parameters:
///     - historical draws: 2D arrays with the sorted hisorical draws
/// - Returns:
///     - the distribution table made of 5 columns and 50 rows ( 1 row per data)
func calculateColumnDistributions(table: [[Int]]) -> [[Int]] {
    //print("Function: calculateColumnDistributions")
    //print("Function: calculateColumnDistributions: Table des tirages \(table)")
    
    var distribution: [[Int]] = Array(repeating: Array(repeating: 0, count: AppConfig.Game.maxNumberValue  + 1), count: AppConfig.Game.drawSize)
    
    // Count occurrences of each number in their actual column positions
    for draw in table {
        for (columnIndex, number) in draw.enumerated() {
            distribution[columnIndex][number] += 1
        }
    }
    
    //print("Function: calculateColumnDistributions: Table de distribution \(distribution)")
    
    return distribution
}
