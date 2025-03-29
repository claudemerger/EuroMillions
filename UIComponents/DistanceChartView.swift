//
//  DistanceChartView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 18/03/2025.
//

import SwiftUI
import Charts

// MARK: - Data Structures

/// Represents a single data point in the distance distribution
/// Used for raw data before grouping
struct DistanceDistributionData: Identifiable {
    /// Unique identifier for each data point
    let id = UUID()
    /// The distance value
    let distance: Int
    /// Number of occurrences of this distance
    let count: Int
}

// MARK: - DistanceChartView
/// A SwiftUI view that displays a bar chart showing the distribution of maximum distances
/// between identical numbers in lottery draws.
///
/// The chart groups the data into intervals of 5 for better readability and displays
/// a customizable subset of x-axis labels to prevent overcrowding.
///
/// - Parameters:
///   - distanceData: Dictionary containing raw distance data where the key is the distance
///                   and the value is the count of occurrences
struct DistanceChartView: View {
    // MARK: - Properties
    
    /// Raw distance distribution data
    let distanceData: [Int: Int]
    /// Controls how often x-axis labels are displayed (e.g., 3 means every third label)
    let labelInterval: Int = 3
    
    // MARK: - Nested Types
    
    /// Internal structure for grouped data representation
    private struct GroupedData: Identifiable {
        let range: Int    // Start of the range
        let count: Int    // Number of occurrences in this range
        var id: Int { range }
        
        /// The full range label (e.g., "10-14") used for tooltips
        var rangeLabel: String {
            "\(range)-\(range+4)"
        }
        
        /// Shortened label (e.g., "10") used for x-axis
        var shortLabel: String {
            "\(range)"
        }
    }
    
    // MARK: - Computed Properties
    
    /// Groups the raw distance data into intervals of 5
    /// For example, distances 0-4 will be grouped together, 5-9 together, etc.
    private var groupedData: [GroupedData] {
        var grouped: [Int: Int] = [:]
        // Group distances into intervals of 5
        for (distance, count) in distanceData {
            let group = (distance / 5) * 5
            grouped[group, default: 0] += count
        }
        
        // Convert to array of GroupedData and sort by range
        return grouped.map { GroupedData(range: $0.key, count: $0.value) }
            .sorted { $0.range < $1.range }
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            // Title section
            Text("Distribution du Max de la distance")
                .font(.title2)
            Text("entre 2 numéros identiques consécutifs")
                .font(.title3)
                .padding(.bottom, 10)
            
            // Chart section
            Chart(groupedData) { group in
                BarMark(
                    x: .value("Distance", group.rangeLabel),
                    y: .value("Nombre", group.count)
                )
                .foregroundStyle(.blue.gradient)
            }
            // X-axis configuration - shows reduced number of labels for clarity
            .chartXAxis {
                AxisMarks { value in
                    let index = groupedData.firstIndex { $0.rangeLabel == value.as(String.self) }
                    if let index = index, index % labelInterval == 0 {
                        AxisValueLabel {
                            Text(groupedData[index].shortLabel)
                        }
                        AxisGridLine()
                    }
                }
            }
            // Y-axis configuration with grid lines every 5 units
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 5)) {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 400)
            .padding()
            
            // Legend section
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                Text("Nombre de tirages par tranche de 5")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// MARK: - Extensions
/*
extension Distribution {
    /// Transforms raw distance table data into a format suitable for charting
    /// - Parameter distanceTable: 2D array containing distance data
    /// - Returns: Array of DistanceDistributionData sorted by distance
    func getChartData(fromDistanceTable distanceTable: [[Int]]) -> [DistanceDistributionData] {
        let distribution = calculateDistributionFromTable(tableInstance: distanceTable)
        
        return distribution.map { (distance, count) in
            DistanceDistributionData(distance: distance, count: count)
        }.sorted { $0.distance < $1.distance }
    }
}
*/
// MARK: - Preview
/*
#Preview {
    // 1. Preview  configuration Set-up: Create an in-memory database configuration
    let previewConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
    let previewContainer = try! ModelContainer(for: GameItem.self, configurations: previewConfiguration)
    
    // Create a mock DataStore with sample data
    let previewDataStore = DataStoreClass.dataStoreInstance(context: previewContainer.mainContext, distanceMax: .constant(147))
    
    // 2. Sample Data:  Create sample distance table
    let sampleDistanceTable = [
        [0, 5, 10, 15],
        [5, 10, 15, 20],
        [10, 15, 20, 25]
    ]
    
    // Create Distribution instance and get chart data
    let distribution = Distribution(dataStoreInstance: previewDataStore)
    let chartData = distribution.getChartData(fromDistanceTable: sampleDistanceTable)
    
    // Convert to the format needed by DistanceChartView
    let distanceData = Dictionary(grouping: chartData) { $0.distance }
        .mapValues { $0.first?.count ?? 0 }
    
    // 3. View Set-up: Create the preview view
    DistanceChartView(distanceData: distanceData)
        .modelContainer(previewContainer)
        .frame(width: 800, height: 600)
}
*/

// MARK: - Preview
/*
#Preview {
    DistanceChartView()
}
*/
