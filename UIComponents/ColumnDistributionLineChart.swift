//
//  ColumnDistributionLineChart.swift
//
//  Created by Claude sur iCloud on 04/12/2024.
//

import SwiftUI
import Charts
import SwiftData

/// A view that displays a line chart showing the distribution of numbers across columns
/// and provides access to detailed data through a popup sheet
struct ColumnDistributionLineChart: View {
    // MARK: - Properties
    
    /// Instance of DataStoreClass containing the lottery data
    let dataStoreBuilder: DataStoreBuilder
    
    /// 2D array containing the distribution data for each column
    /// First dimension represents columns (0-4)
    /// Second dimension represents numbers (1-49)
    /// Value at each position represents frequency
    let distribution: [[Int]]
    let totalDraws: Int
    
    /// State variable to control the visibility of the data sheet
    @State private var showingDataSheet = false
    
    // MARK: - Data Structures
    
    /// Structure to hold individual data points for the chart
    struct ChartData: Identifiable {
        let id = UUID()
        let number: Int      // The lottery number (1-50)
        let column: Int      // The column number (1-5)
        let frequency: Int   // How many times this number appears in this column
    }
    
    // MARK: - Computed Properties
    
    /// Processes the raw distribution data into a format suitable for the chart
    private var chartData: [ChartData] {
        var data: [ChartData] = []
        
        // Convert the 2D array into individual data points
        for column in 0..<AppConfig.Game.drawSize  {
            for number in 1..<AppConfig.Game.maxNumberValue + 1 {
                data.append(ChartData(
                    number: number,
                    column: column + 1,
                    frequency: distribution[column][number]
                ))
            }
        }
        return data
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header with title and data button
            HStack {
                Text("Graphique de la distribution des N° par colonne")
                    .font(.headline)
                
                Spacer()
                
                // Print button
                    Button(action: {
                        printChart()
                    }) {
                        Image(systemName: "printer")
                        Text("Impression")
                    }
                    .buttonStyle(.bordered)
                
                // Button to show the detailed data sheet
                Button(action: {
                    showingDataSheet = true
                }) {
                    Image(systemName: "table")
                    Text("Données")
                } // end of Button
                .buttonStyle(.bordered)
            } // end of HStack
            .padding(.bottom)
            
            // Line chart displaying the distribution
            Chart(chartData) { point in
                // Add reference lines first (so they appear behind the data)
                RuleMark(y: .value("5%", Double(totalDraws) * 0.005))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.gray.opacity(0.5))

                RuleMark(y: .value("10%", Double(totalDraws) * 0.010))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.gray.opacity(0.5))

                RuleMark(y: .value("20%", Double(totalDraws) * 0.020))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.gray.opacity(0.5))
                
                // Your existing LineMark
                LineMark(
                    x: .value("N°", point.number),
                    y: .value("Frequence", point.frequency)
                )
                .foregroundStyle(by: .value("Colonne", "Colonne \(point.column)"))
            } // end of Chart
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 10))
            } // end of chartAxis
            .chartYAxis {
                AxisMarks(position: .leading)
            } // end of chartAxis
            .chartLegend(position: .top)
            //.frame(maxHeight: .infinity)
            .frame(minHeight: 300, maxHeight: .infinity)   // change valut to modify chart height
        } // end of VStack
        .border(Color.blue, width: 1)
        .padding(20)
        .frame(width: 600, height: 400)  // Adjust these values as needed
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .sheet(isPresented: $showingDataSheet) {
            DataSheetView(distribution: distribution)
        } // end of sheet
    } // end of body
    
    // MARK: - Print function
    ///
    /// This function will print a screenshot of the graphics.
    private func printChart() {
        // First create NSView from our chart
        let printView = NSHostingView(rootView: self)
        printView.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        printView.layout()
        
        // Create a bitmap representation
        guard let bitmapRep = printView.bitmapImageRepForCachingDisplay(in: printView.bounds) else { return }
        printView.cacheDisplay(in: printView.bounds, to: bitmapRep)
        
        let printInfo = NSPrintInfo.shared
        printInfo.orientation = .landscape
        printInfo.topMargin = 20
        printInfo.bottomMargin = 20
        printInfo.leftMargin = 20
        printInfo.rightMargin = 20
        
        // Create an NSImageView with our captured image
        let image = NSImage(size: printView.bounds.size)
        image.addRepresentation(bitmapRep)
        let imageView = NSImageView(frame: printView.bounds)
        imageView.image = image
        
        // Create and run print operation
        let operation = NSPrintOperation(view: imageView, printInfo: printInfo)
        operation.showsPrintPanel = true
        
        DispatchQueue.main.async {
            operation.run()
        }
    } // end of func printChart
    
} // end of Struct ColumnDistributionLineChart


/// A view that displays the detailed distribution data in a grid format
struct DataSheetView: View {
    // MARK: - Properties
    
    /// The distribution data to display
    let distribution: [[Int]]
    
    /// Environment variable to handle sheet dismissal
    @Environment(\.dismiss) var dismiss
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            // Header with title and close button
            HStack {
                Text("Données")
                    .font(.headline)
                Spacer()
                Button("Fermer") {
                    dismiss()
                }
            } // end of HStack
            .padding()
            
            // Grid display of distribution data
            ScrollView {
                Grid(alignment: .leading) {
                    // Header row with column titles
                    GridRow {
                        Text("Numéro")
                            .gridColumnAlignment(.trailing)
                        ForEach(Array(0..<AppConfig.Game.drawSize), id: \.self) { i in
                            Text("Col \(i+1)")
                                .gridColumnAlignment(.trailing)
                        }
                    } // end of GridRow
                    .bold()
                    
                    Divider()
                    
                    // Data rows showing frequencies
                    ForEach(Array(1..<AppConfig.Game.maxNumberValue + 1), id: \.self) { number in
                        if distribution.contains(where: { $0[number] > 0 }) {
                            GridRow {
                                Text("\(number)")
                                    .gridColumnAlignment(.trailing)
                                ForEach(Array(0..<AppConfig.Game.drawSize), id: \.self) { column in
                                    Text("\(distribution[column][number])")
                                        .gridColumnAlignment(.trailing)
                                } // end of ForEach
                            } // end of GridRow
                        } // end of if
                    } // end of ForEach
                } // end of Grid
                .padding()
            } // end of ScrollView
        } // end of main VStack
        .border(Color.blue)
        .frame(width: 400, height: 600)
    }
}

// MARK: - Preview Provider
/*
#Preview {
    // Create sample data for preview
    let sampleDistributions = Array(repeating: Array(repeating: 0, count: AppConfig.Game.maxNumberValue ), count: AppConfig.Game.drawSize)
    
    ColumnDistributionLineChart(
        appDataStore: AppDataStore(
            context: try! ModelContainer(for: GameItem.self,
                                         configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext, distanceMax: .constant(147)
        ),
        distributions: sampleDistributions,
        totalDraws: 100
    )
}
*/
