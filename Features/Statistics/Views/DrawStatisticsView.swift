//
//  DrawStatisticsView.swift
//  EuroMillionsResults
//
//  Created on 27/02/2025.
//

import SwiftUI
import SwiftData

/// View that displays statistical analysis of EuroMillions draws
/// Provides analysis features including:
/// - Pattern analysis comparing selected draw with historical data
/// - Distribution of matching numbers between draws
struct DrawStatisticsView: View {
    
    // MARK: - Properties
    
    /// Reference to the central data store containing all draw information
    var dataStoreBuilder: DataStoreBuilder
    
    /// The index of the currently selected draw for analysis
    /// This allows the view to analyze the specific draw the user is viewing
    let selectedDrawIndex: Int
    
    /// Flag to track if analysis has been performed
    /// Used to control display of analysis results
    @State private var analysisPerformed: Bool = false
    
    /// Contains the distribution of matching numbers between the selected draw and all other draws
    /// Array indices represent the number of matching numbers (0-5)
    /// Values represent how many draws have that many matches with the selected draw
    @State private var matchingNumbersDistribution: [Int] = Array(repeating: 0, count: 6)
    
    // MARK: - View Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Main section title
            Text("Analyse des tirages")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)
                        
            // Pattern analysis section
            VStack(alignment: .leading) {
                // Analysis header
                Text("Analyse Signature")
                    .font(.headline)
                
                // Description of the analysis
                Text("Nombre de numéros identiques entre le tirage et l'historique:")
                    .font(.subheadline)
                
                // Display results as a row of numbers
                HStack {
                    // Each box shows how many draws have X matching numbers with the current draw
                    ForEach(0..<matchingNumbersDistribution.count, id: \.self) { index in
                        VStack {
                            // Number of matches
                            Text("\(index)")
                                .font(.caption)
                            
                            // Count of draws with this many matches
                            Text("\(matchingNumbersDistribution[index])")
                                .font(.body)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
                        .frame(minWidth: 40)
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.vertical)
                
                // Button to trigger the analysis
                Button("Analyse Signature") {
                    analyzePattern()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    // MARK: - Analysis Methods
    
    /// Analyzes the pattern of matching numbers between the selected draw and all historical draws
    /// Updates the matchingNumbersDistribution array with the results
    private func analyzePattern() {
        // Verify that we have data and a valid selection
        guard !dataStoreBuilder.draws.isEmpty, selectedDrawIndex < dataStoreBuilder.draws.count else {
            return
        }
        
        // Reset the distribution to all zeros
        matchingNumbersDistribution = Array(repeating: 0, count: 6)
        
        // Get the main numbers from the selected draw
        let selectedDrawNumbers = Array(dataStoreBuilder.draws[selectedDrawIndex].prefix(5))
        
        // Compare with each historical draw
        for (index, draw) in dataStoreBuilder.draws.enumerated() {
            // Skip comparing with itself
            if index == selectedDrawIndex {
                continue
            }
            
            // Count how many numbers match between the two draws
            let historicalDrawNumbers = Array(draw.prefix(5))
            let matchingCount = selectedDrawNumbers.filter { historicalDrawNumbers.contains($0) }.count
            
            // Update the distribution count for this matching level
            matchingNumbersDistribution[matchingCount] += 1
        }
        
        // Mark analysis as performed to update the UI
        analysisPerformed = true
    }
}

// MARK: - Supporting Views

/// Horizontal bar that displays frequency information
/// Used to show data like most frequent numbers or stars
struct FrequencyStatusBar: View {
    /// Title describing the frequency data
    let title: String
    
    /// Array of strings with frequency data to display
    let data: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
            
            HStack {
                ForEach(data, id: \.self) { item in
                    Text(item)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Preview
/*
#Preview {
    do {
        let previewDataStoreBuilder = try DataStoreBuilder()
        // Add some preview data if needed
        if previewDataStoreBuilder.draws.isEmpty {
            previewDataStoreBuilder.draws = [[5, 17, 23, 32, 46], [9, 11, 13, 21, 32], [3, 25, 27, 34, 50]]
            previewDataStoreBuilder.stars = [[3, 9], [2, 7], [4, 8]]
            previewDataStoreBuilder.drawDates = [Date(), Date().addingTimeInterval(-604800), Date().addingTimeInterval(-1209600)]
        }
        
        DrawStatisticsView(dataStoreBuilder: previewDataStoreBuilder, selectedDrawIndex: 0)
            .frame(width: 600, height: 500)
    } catch {
        Text("Error creating preview: \(error.localizedDescription)")
    }
}
*/
