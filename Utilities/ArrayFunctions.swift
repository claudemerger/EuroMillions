//
//  ArrayFunctions.swift
//  Loto
//
//  Created by Claude sur iCloud on 02/11/2024.
//

import Foundation

/// Sort array function
func sortArray<T: Comparable>(_ array: [T]) -> [T] {
    return array.sorted()
}

/// Function qui compare une array à une table d'array et retourne une array de la répartition du nombre de n° identiques entre l'array et la table d'array
func compareArrayToTable(_ array: [Int], _ table: [[Int]]) -> [Int] {
    //debugPrint("compareArrayToTable")
    
    var matchArray: [Int] = Array(repeating: 0, count: 6)
    var mutableTable = table  // Create a local mutable copy
    
    /// if the array is identical to the top of the table, remove the top. this hammens wwhen comparing the current draw to the historical draws
    if array == mutableTable[0] {
        mutableTable.remove(at: 0)
    }
    
    for row in mutableTable {
        let matches = countMatchesArrayToArray(array, row)
        matchArray[matches] += 1
    }
    //debugPrint("matchArray", matchArray)
    return matchArray
} // end of compareArrayToTable


/// Fonction qui compare 2 arrays de nombres et donne le nombre de numéros identiques entre les 2 arrays
func countMatchesArrayToArray (_ array1: [Int], _ array2: [Int]) -> Int {
    //debugPrint("countMatchesArrayToArray")
    
    let set1 = Set(array1)
    let set2 = Set(array2)
    //debugPrint(" nombre de numéros identiques entre 2 arrays", set1.intersection(set2).count)
    return set1.intersection(set2).count
}

/// This  function compares an array to a table and returns a list with the number of matches between the array and each array of the table
func countMatchesArrayToTable(_ array: [Int], _ table: [[Int]]) -> [Int] {
    //debugPrint("countMatchesArrayToTable")
    
    var listOfMatches:[Int] = []
    
    for row in table {
        var matchCount: Int = 0
        matchCount = countMatchesArrayToArray(array, row)
        listOfMatches.append(matchCount)
    }
    return listOfMatches
}

/// Fonction qui calcule les valeurs minimum et valeurs maximun des colonnes d'une table
func computeMinMax (table: [[Int]]) -> [[Int]] {
    //debugPrint("computeMinMax")
    var result = [[Int]](repeating: [Int](repeating: 0, count: 6), count: 2)
    
    for column in 0..<6 {
        let columnValues = table.map { $0[column] }
        result[0][column] = columnValues.min() ?? 0 // Min value for the column
        result[1][column] = columnValues.max() ?? 0 // Max value for the column
    }
    return result
}

/// This function returns the max value of an array
func maxMatch(array: [Int]) -> Int {
    //debugPrint("maxMatch")
    let maxMatch = array.max() ?? 0
    //debugPrint("maxMatch: \(maxMatch)")
    return maxMatch
} // end of func maxMatchArray


/// This function returns the draw at index from the table des tirages
func getTirage(_ table: [[Int]], _ index: Int) -> [Int] {
    debugPrint("getTirage")
    return table[index]
} // end of func getTirage


/// This function removes a row in a 2D Array which contains a specific value
func removeRows<T: Equatable>(containing value: T, from array: inout [[T]]) {
    array = array.filter { row in
        !row.contains(value)
    }
}

/// This function retuns the maximum value of a 2D array
func maxValue(_ array: [[Int]]) -> Int {
   array.flatMap { $0 }.max() ?? 0
}
