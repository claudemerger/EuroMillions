//
//  DistanceDistributionFunctions.swift

//
//  Created by Claude sur iCloud on 04/03/2025.
//



// DistanceDistributionFunctions.swift
import Foundation

/// This structure handles distance calculations and analysis
struct DistanceDistribution {
    // MARK: - Properties
    
    /// The generator for distance tables
    private let generateDistanceTableInstance: GenerateDistanceTable
    
    // MARK: - Initialization
    
    init(generateDistanceTableInstance: GenerateDistanceTable) {
        self.generateDistanceTableInstance = generateDistanceTableInstance
    }
    
    // MARK: - Public Methods
    
    /// Generates the distribution of maximum distances from a table
    /// - Parameter table: The distance table to analyze
    /// - Returns: A dictionary with distance values as keys and occurrence counts as values
    func generateMaxDistanceDistribution(table: [[Int]]) -> [Int: Int] {
        let maxDistanceList = maxDistanceList(table: table)
        let distribution = calculateDistribution(list: maxDistanceList)
        return distribution
    }
    
    /// Calculates the maximum distance value for a given percentage of draws
    /// - Parameters:
    ///   - percentage: The percentage threshold (e.g., 80%)
    ///   - distribution: The distribution dictionary from generateMaxDistanceDistribution
    /// - Returns: The distance value that includes at least the given percentage of draws
    func getDistanceForPercentage(_ percentage: Int, from distribution: [Int: Int]) -> Int {
        let totalCount = distribution.values.reduce(0, +)
        if totalCount == 0 {
            return 0 // Protect against division by zero
        }
        
        var cumulativeCount = 0
        
        // Sort the distribution by distance value (key)
        let sortedDistribution = distribution.sorted { $0.key < $1.key }
        
        // Find the first distance value that exceeds our target percentage
        for (distance, count) in sortedDistribution {
            cumulativeCount += count
            let currentPercentage = (Double(cumulativeCount) / Double(totalCount)) * 100
            
            if currentPercentage >= Double(percentage) {
                return distance
            }
        }
        
        // If we haven't found a value, return the maximum distance
        return sortedDistribution.last?.key ?? 0
    }
    
    // MARK: - Helper Methods
    
    /// Gets a list of maximum distances for each row in the table
    private func maxDistanceList(table: [[Int]]) -> [Int] {
        return calculateMaxDistanceList(table: table)
    }
    
    /// Calculates the maximum value in each row of the table
    private func calculateMaxDistanceList(table: [[Int]]) -> [Int] {
        var maxDistanceList: [Int] = []
        
        for row in table {
            // Skip empty rows
            if row.isEmpty {
                continue
            }
            
            let sortedRow = sortArray(row)
            if let maxValue = sortedRow.last {
                maxDistanceList.append(maxValue)
            }
        }
        
        return maxDistanceList
    }
    
    /// Sorts an array of integers in ascending order
    private func sortArray(_ array: [Int]) -> [Int] {
        return array.sorted()
    }
    
    /// Calculates the frequency distribution of values in a list
    private func calculateDistribution(list: [Int]) -> [Int: Int] {
        return list.reduce(into: [:]) { counts, value in
            counts[value, default: 0] += 1
        }
    }
}
/*
import Foundation

/// This structure calculates the distribution of the maximum value of the distance  table.
/// It calculates the maximum value of each row in the distance table and stores it in the maxDistanceList.
/// This list is then used to calculate the distribution table of those values.
/// This distribution will be used to determine the distance value that will allow  to select n% (80%) of the draws.
struct DistanceDistribution {
    
    // MARK: - properties
    private var generateDistanceTableInstance: GenerateDistanceTable             // GenerateDistanceTable Instance
    
    private(set) var distanceDistributionDictionary: [Int: Int]
    
    private var appDataStore: AppDataStore
    
    // MARK: - Initialization
    init(generateDistanceTableInstance: GenerateDistanceTable, appDataStore: AppDataStore) {
        self.generateDistanceTableInstance = generateDistanceTableInstance
        self.distanceDistributionDictionary = [0: 0]
        self.appDataStore = appDataStore  // Store the reference
    }
    
    // MARK: - Methods
    /// This function generates the maxDistanceList from the distanceTable
    @MainActor
    func generateMaxDistanceDistribution(table: [[Int]]) -> [Int: Int] {
        // step1: calculates the list of the maximum distance per row from the distance table
        let maxDistanceList = maxDistanceList(table: table)
        // step2: calculate the distribution of the maxDistanceList
        let distribution = calculateDistribution(list: maxDistanceList)
        //printDistribution(distribution: distribution)
        return distribution
    }
    
    
    /// This function calculates the list of the maximum distance from the source table
    @MainActor
    func maxDistanceList(table: [[Int]]) -> [Int] {
        // generates the list of the maximum values for each row of the distance table
        let maxDistanceList = calculateMaxDistanceList(table: table)
        //print ("maxDistanceList: \(maxDistanceList)")
        //print("maxDistanceList.count: \(maxDistanceList.count)")
        return maxDistanceList
    }
    
    /// This function calculates the distribution of the maxDistanceList values
    @MainActor
    func calculateMaxDistanceDistribution (maxDistanceList: [Int]) -> [Int] {
        //var uniqueValues = Array(Set(maxDistanceList)).sorted() // [1, 2, 3, 4]
        var frequencies: [Int] = [] // Will hold counts in same order as uniqueValues
        
        // Count frequencies
        for value in maxDistanceList {
            let count = maxDistanceList.filter { $0 == value }.count
            frequencies.append(count)
        }
        
        // Now uniqueValues[i] corresponds to frequencies[i]
        // You can easily sort both arrays based on frequency
        let sorted = zip(maxDistanceList, frequencies)
            .sorted { $0.1 > $1.1 } // Sort by frequency in descending order
        
        /*
        // Print results
        for (value, freq) in sorted {
            print("\(value): \(freq)")
        }
        print ("frequency: \(frequencies)")
        */
        return frequencies
    }
    
    /// Calculates the maximum distance list for every draws from the distance table.
    /// This function returns a list (1D array) with the max value of each row of the source table
    func calculateMaxDistanceList(table: [[Int]]) -> [Int] {
        var sortedDistanceArray: [Int] = []
        var maxDistanceList: [Int] = []
        for row in 0...table.count-1 {
            sortedDistanceArray = sortArray(table[row])
            maxDistanceList.append(sortedDistanceArray.last!)
        }
        return maxDistanceList
    }
    
    /// Calculates the distribution of a list of integer values
    func calculateDistribution(list: [Int]) -> [Int: Int] {
        /// Distribution contains key-value pairs where:
        /// key = the integer value
        /// value = how many times it appears
        let distribution = list.reduce(into: [:]) { counts, value in
            counts[value, default: 0] += 1
        }
        return distribution
    }
    
    // Add this function to update the distance max
    @MainActor
    func updateDistanceMax() {
        let maxDistanceDistribution = generateMaxDistanceDistribution(
            table: appDataStore.distanceTable
        )
        AppSettings.shared.distanceMax = getDistanceForPercentage(
            AppSettings.shared.defaultPercentageValue,
            from: maxDistanceDistribution
        )
    }

    
    /*
    /// Prints the distribution
    func printDistribution(distribution: [Int: Int]) {
        for (value, count) in distribution.sorted(by: { $0.key < $1.key }) {
            print("Value \(value): \(count) times")
        }
    }
    
    /// Returns the percentage of a value in a distribution dictionary
    func getPercentageDistribution(distribution: [Int: Int]) -> Double {
        let total = Double(distribution.values.count)
        var percentage: Double = 0
        for (value, count) in distribution {
            percentage = (Double(count) / total) * 100
            print("Value \(value): \(percentage)%")
        }
        return percentage
    }
    */
} // end of Struct Distance Distribution


// MARK: -

extension DistanceDistribution {
    /// This function returns the maximum distance for a given  percentage of the draws which meets that value
    func getDistanceForPercentage(_ percentage: Int, from distribution: [Int: Int]) -> Int {
        let totalCount = distribution.values.reduce(0, +)
        var cumulativeCount = 0
        
        // Sort the distribution by distance value (key)
        let sortedDistribution = distribution.sorted { $0.key < $1.key }
        
        // Find the first distance value that exceeds our target percentage
        for (distance, count) in sortedDistribution {
            cumulativeCount += count
            let currentPercentage = (Double(cumulativeCount) / Double(totalCount)) * 100
            
            if currentPercentage >= Double(percentage) {
                return distance
            }
        }
        
        // If we haven't found a value, return the maximum distance
        return sortedDistribution.last?.key ?? 0
    }
}
*/
