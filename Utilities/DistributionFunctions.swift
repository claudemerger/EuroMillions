//
//  DistributionFunctions.swift
//  Loto
//
//  Created by Claude sur iCloud on 23/12/2024.
//

import Foundation

// MARK: Distribution Functions

/// Analyzes a 1D array of integers and generates a distribution count of values.
///
/// - Parameters:
///   - list: The source array of integers to analyze
///   - maxValue: The maximum value to track in the distribution (default: 5)
///
/// - Returns: An array where the index represents the value and the element
///            represents how many times that value appears in the source list
///
/// Example: If input is [1, 2, 2, 3, 3, 3], the output will be [0, 1, 2, 3, 0, 0]
/// (0 appears 0 times, 1 appears 1 time, 2 appears 2 times, etc.)
func generateDistributionFrom1DArray(from list: [Int], maxValue: Int = 5) -> [Int] {
    // Initialize array with zeros for counts from 0 to maxValue
    var distribution = Array(repeating: 0, count: maxValue + 1)
    
    // Count occurrences of each number
    for value in list {
        if value >= 0 && value <= maxValue {
            distribution[value] += 1
        }
    }
    return distribution
}


/// Analyzes a 2D array of integers and generates a distribution count as a 2D array.
///
/// - Parameter dataArray: The source 2D array of integers to analyze
///
/// - Returns: A 2D array where:
///   - The first row contains the possible values (0 to max value found)
///   - The second row contains the count of occurrences for each value
///
/// This function is particularly useful for visualizing distribution patterns
/// in lottery draw data.
func generateDistributionArrayFromArray(from dataArray: [[Int]]) -> [[Int]] {
    let maxValue = dataArray.flatMap { $0 }.max() ?? 0
    let values = Array(0...maxValue)
    var counts = Array(repeating: 0, count: maxValue + 1)
    
    for row in dataArray {
        for value in row {
            counts[value] += 1
        }
    }
    //print("values: \(values)")
    //print(" Counts:  \(counts)")
    //print("Values: \(values)  Counts: \(counts))")
    return [values, counts]
}

/// Analyzes a 2D array of integers and generates a distribution as a dictionary.
///
/// - Parameter sourceArray: The source 2D array of integers to analyze
///
/// - Returns: A dictionary where keys are the values found in the source array
///            and values are the count of occurrences
///
/// This representation is useful for efficient lookup of how many times
/// a specific number appears in the dataset.
public func generateDistributionDictionaryFromArray(sourceArray: [[Int]]) -> [Int: Int] {
    /// This function generates a dictionary which count the number of occurences of each data in the source array
    var distribution: [Int: Int] = [:]
    //print("Source array size: \(sourceArray.count) x \(sourceArray.first?.count ?? 0)")
    //print("Sample values: \(sourceArray.prefix(2))")
    
    for row in sourceArray {
        for value in row {
            distribution[value, default: 0] += 1
        }
    }
    
    //print("Generated distribution: \(distribution)")
    return distribution
}


/// Converts a distribution dictionary back into a 2D array, with values
/// distributed randomly.
///
/// - Parameter distribution: A dictionary mapping values to their frequency counts
///
/// - Returns: A 2D array containing the values from the dictionary repeated
///            according to their frequency, arranged in a roughly square shape
///
/// The resulting array has the values shuffled randomly to avoid patterns,
/// which is useful for simulations or testing with realistic data distributions.
func generateArrayFromDistributionDictionary(from distribution: [Int: Int]) -> [[Int]] {
   // Calculate total elements and determine array dimensions
   let total = distribution.values.reduce(0, +)
   let size = Int(sqrt(Double(total)))
   
   // Create flat array with all values
   var values: [Int] = []
   for (number, count) in distribution {
       values += Array(repeating: number, count: count)
   }
   values.shuffle() // Randomize distribution
   
   // Convert to 2D array
   var result: [[Int]] = []
   for i in stride(from: 0, to: values.count, by: size) {
       let row = Array(values[i..<min(i + size, values.count)])
       result.append(row)
   }
   
   return result
}
