//
//  StatisticsAnalysisFramework.swift
//
//  Created by Claude sur iCloud on 19/11/2024.
//

import SwiftUI

// MARK: - Protocols
protocol StatisticalAnalysis {
    var title: String { get }
    var description: String { get }
    var dataPoints: Int { get }
    
    mutating func getDataPoints(from data: [[Int]]) -> Int
    func calculate(historicalData: [[Int]]) -> [Int]
    func formatResult(_ value: Int) -> String
    // Add method to dynamically get dataPoints from input data
}

// MARK: - Base Implementation
struct BaseStatView<T: StatisticalAnalysis>: View {
    
    let dataStoreBuilder:DataStoreBuilder
    
    @State var analysis: T  // Changed from let to @State
    @State private var result: [Int] = []
    
    // MARK: - Body
    var body: some View {
        
        // Container
        VStack(alignment: .leading) {
            
            Text(analysis.title)
                .font(.headline)
                .padding(AppConfig.UI.Padding.none)
            
            Text(analysis.description)
            
            // view Array
            ArrayView<Int>(data: result)
            
        } // end of Container
        /*
        .frame(width: AppConfig.UI.Container.largeWidth - 10, height: AppConfig.UI.Container.smallHeight)
        .padding(AppConfig.UI.Padding.small)
        .padding(.bottom, 0)
        .padding(.top, 0)
        .border(Color.gray, width: 1)
        */
         
        .onAppear {
            let historicalData = dataStoreBuilder.draws
            _ = analysis.getDataPoints(from: historicalData)  // Initialize dataPoints
            result = analysis.calculate(historicalData: historicalData)
        } // end of onAppear
        
    } // end of body
    
} // end of struct


// MARK: - Specific Implementations

struct IdenticalNumbersAnalysis: StatisticalAnalysis {
    let title = "Distribution du nombre de numéros identiques"
    let description = "Calcul de la distribution dans la table des tirages du nombre de numéros identiques entre 2 tirages."
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        //dataPoints = (data.flatMap { $0 }.max() ?? 0) + 1
        dataPoints = 6
        return dataPoints
    }
    func calculate(historicalData: [[Int]]) -> [Int] {
        guard let firstDraw = historicalData.first else { return Array(repeating: 0, count: dataPoints) }
        return compareArrayToTable(firstDraw, historicalData) ?? Array(repeating: 0, count: dataPoints) // warning not a problem
    }
    
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}

// MARK: - Parity analysis

struct OddEvenAnalysis: StatisticalAnalysis {
    let title = "Distribution Pairs/Impairs"
    let description = "Distribution des Numéros pairs/impairs"
    //let dataPoints = 6
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        dataPoints = 6
        return dataPoints
    }
    
    func calculate(historicalData: [[Int]]) -> [Int] {
        var distribution = Array(repeating: 0, count: dataPoints)
        for draw in historicalData {
            let oddCount = draw.filter { $0 % 2 != 0 }.count
            distribution[oddCount] += 1
        }
        return distribution
    }
    
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}

// MARK: - Consecutive numbers analysis

struct ConsecutiveNumbersAnalysis: StatisticalAnalysis {
    let title = "Distribution des Numéros Consécutifs"
    let description = "Distribution du nombre de numéros consécutifs dans chaque tirage"
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        //dataPoints = (data.flatMap { $0 }.max() ?? 0) + 1
        dataPoints = 6
        return dataPoints
    }
    
    func calculate(historicalData: [[Int]]) -> [Int] {
        var distribution = Array(repeating: 0, count: dataPoints)
        
        for draw in historicalData {
            let sortedDraw = draw.sorted()
            var consecutiveSets = 0
            
            for i in 1..<sortedDraw.count {
                if sortedDraw[i] == sortedDraw[i-1] + 1 {
                    if i == 1 || sortedDraw[i-1] != sortedDraw[i-2] + 1 {
                        consecutiveSets += 1
                    }
                }
            }
            
            distribution[consecutiveSets] += 1
        }
        
        return distribution
    }
    
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}

/*
// MARK: - Weight analysis
/// This structure calculates the distribution of the number of occurences for a given distance.
/// An occurence is the number of times a number shows up in a given range.
struct OccurencesAnalysis: StatisticalAnalysis {
    let title = "Distribution des groupes"
    let description = "Distribution des groupes pour une distance donnée"
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        dataPoints = (data.flatMap { $0 }.max() ?? 0) + 1
        return dataPoints
    }
    
    func calculate(historicalData: [[Int]]) -> [Int] {
        let size = (historicalData.flatMap { $0 }.max() ?? 0) + 1
        var distribution = Array(repeating: 0, count: size)
        
        for row in historicalData {
            for value in row {
                if value < size {
                    distribution[value] += 1
                }
            }
        }
        return distribution
    }
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}
*/

// MARK: - 7x7 grid analysis

struct GridAnalysis {
    static let gridSize = 7
    static let maxNumbersPerLine = 5
    
    static func createGrid(_ number: Int) -> (row: Int, col: Int) {
        let row = (number - 1) / gridSize
        let col = (number - 1) % gridSize
        return (row, col)
    }
}

struct GridRowAnalysis: StatisticalAnalysis {
    let title = "Distribution par Rangée (Grille 7x7)"
    let description = "Nombre de tirages ayant N numéros dans une même rangée"
    //let dataPoints = 5  // Maximum 5 numbers per draw
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        //dataPoints = (data.flatMap { $0 }.max() ?? 0) + 1
        dataPoints = 5
        return dataPoints
    }
    
    func calculate(historicalData: [[Int]]) -> [Int] {
        var distribution = Array(repeating: 0, count: dataPoints)
        
        for draw in historicalData {
            var rowCounts = Array(repeating: 0, count: GridAnalysis.gridSize)
            
            // Count numbers in each row for this draw
            for number in draw {
                let position = GridAnalysis.createGrid(number)
                rowCounts[position.row] += 1
            }
            
            // Find max numbers in any row for this draw
            if let maxInRow = rowCounts.max(), maxInRow > 0 {
                distribution[maxInRow - 1] += 1
            }
        }
        
        return distribution
    }
    
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}

struct GridColumnAnalysis: StatisticalAnalysis {
    let title = "Distribution par Colonne (Grille 7x7)"
    let description = "Nombre de tirages ayant N numéros dans une même colonne"
    //let dataPoints = 5  // Maximum 5 numbers per draw
    private(set) var dataPoints: Int = 0
    
    mutating func getDataPoints(from data: [[Int]]) -> Int {
        //dataPoints = (data.flatMap { $0 }.max() ?? 0) + 1
        dataPoints = 5
        return dataPoints
    }
    
    
    
    func calculate(historicalData: [[Int]]) -> [Int] {
        var distribution = Array(repeating: 0, count: dataPoints)
        
        for draw in historicalData {
            var colCounts = Array(repeating: 0, count: GridAnalysis.gridSize)
            
            // Count numbers in each column for this draw
            for number in draw {
                let position = GridAnalysis.createGrid(number)
                colCounts[position.col] += 1
            }
            
            // Find max numbers in any column for this draw
            if let maxInColumn = colCounts.max(), maxInColumn > 0 {
                distribution[maxInColumn - 1] += 1
            }
        }
        
        return distribution
    }
    
    func formatResult(_ value: Int) -> String {
        return "\(value)"
    }
}

// MARK: 5x10 Grid analysis

