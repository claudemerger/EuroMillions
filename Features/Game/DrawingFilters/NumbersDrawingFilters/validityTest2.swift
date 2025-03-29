//
//  validityTest2.swift
//  Loto
//
//  Created by Claude sur iCloud on 03/02/2025.
//

import Foundation



/// Test2: Comparison of the game to the draws of the historical draws table.
/// The profile of the result of this comparison should match the historical comparison profile
func validityTest2b(game: [Int], table: [[Int]]) -> Bool {
    //print("validityTest2b")
    //print("Nombre de tirages de la table des tirages: \(table.count)")
    
    let historicalDrawsProfilePercentage = [0.58, 0.37, 0.08, 0.01, 0 , 0]
    let tableCount = table.count
    
    var historicalDrawsProfile = Array(repeating: 0, count: historicalDrawsProfilePercentage.count)
    for (index, percentage) in historicalDrawsProfilePercentage.enumerated() {
        historicalDrawsProfile[index] = Int(Double(tableCount) * percentage)
    }
    //print("historical draws profile: \(historicalDrawsProfile)")
    
    /// Compute the game profile by comparing the game to the draws of the historical draws table.
    /// The profile is the distribution of identical numbers between the game and each draw of the historical draws table.
    let gameProfile = compareGameToHistoricalDrawsTable(game: game, table: table)
    //print("gameProfile: \(gameProfile)")
    
    /// Test of the game profile versus the historical draws profile
    for (index, value) in gameProfile.enumerated() {
        if value > historicalDrawsProfile[index] {
            return false
        }
    }
    
    return true
}


/// This function compares a game to the draws of the historical draws table and returns the number of number match per draw
func compareGameToHistoricalDrawsTable(game: [Int], table: [[Int]]) -> [Int] {
    //print("compareGameToHistoricalDrawsTable")
    
    //let currentDraw: [Int] = drawtable[currentDrawIndex]
    var numberOfIdenticalNumbersArray: [Int] = []
    var distributionOfNumberOfIdenticalNumbers: [Int] = []
    
    /// generates a list of the number of identical numbers between the game and each draw of the drawTable
    for tableIndex in 0..<table.count {
        numberOfIdenticalNumbersArray.append(compareGameToDraw(game: game, draw: table[tableIndex]))
    }
    
    /// generates a distribution of  the number of identical numbers
    distributionOfNumberOfIdenticalNumbers = generateDistributionFrom1DArray(from: numberOfIdenticalNumbersArray)
    
    //print("Number of identical numbers array: \(distributionOfNumberOfIdenticalNumbers)  \n")
    return distributionOfNumberOfIdenticalNumbers
}


/// This function compares a game to a draw
func compareGameToDraw(game: [Int], draw: [Int]) -> Int {
    game.filter { draw.contains($0) }.count
}
