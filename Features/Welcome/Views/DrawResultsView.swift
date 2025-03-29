//
//  DrawResultsView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 18/03/2025.
//

import SwiftUI

/// View that displays EuroMillions draw results with navigation capabilities
/// Provides a user interface to:
/// - View the date of the selected draw
/// - See the 5 main numbers drawn
/// - See the 2 star numbers drawn
/// - Navigate between different historical draws
struct DrawResultsView: View {
    
    // MARK: - Properties
    
    /// Reference to the central data store containing all draw information
    /// This is passed directly from the parent view
    var dataStoreBuilder: DataStoreBuilder
    
    /// Two-way binding to the selected draw index
    /// This allows navigation actions to update the parent view's state
    @Binding var selectedIndex: Int
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 10) {
            // Title section
            HStack {
                Text("Résultats du tirage")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
            }
            
            // Results display section
            HStack(spacing: 20) {
                // Date display with navigation controls
                VStack {
                    Text("Date")
                        .font(.headline)
                        .frame(width: 150)
                    
                    HStack {
                        // Display formatted date of the selected draw
                        Text(getDrawDate())
                            .frame(width: 120, height: 30)
                            .padding(.horizontal, 5)
                        
                        // Navigation arrows for moving between draws
                        VStack(spacing: 0) {
                            // Up arrow - go to older draw (higher index)
                            Button(action: moveUp) {
                                Image(systemName: "arrow.up")
                                    .frame(width: 10, height: 10)
                            }
                            .disabled(selectedIndex == 0)
                            
                            // Down arrow - go to newer draw (lower index)
                            Button(action: moveDown) {
                                Image(systemName: "arrow.down")
                                    .frame(width: 10, height: 10)
                            }
                            .disabled(selectedIndex >= dataStoreBuilder.draws.count - 1)
                        }
                        .padding(.top, 0)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                
                // Main numbers display section
                VStack {
                    Text("Numéros sortis")
                        .font(.headline)
                        .frame(width: 250)
                    
                    // Display the 5 main numbers as blue circles
                    HStack {
                        ForEach(getDrawNumbers(), id: \.self) { number in
                            Text("\(number)")
                                .frame(width: 40, height: 40)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(Color.white)
                                .cornerRadius(20)
                        }
                    }
                }
                
                // Lucky stars display section
                VStack {
                    Text("Etoiles")
                        .font(.headline)
                    
                    // Display the 2 star numbers as yellow circles
                    HStack {
                        ForEach(getDrawStars(), id: \.self) { star in
                            Text("\(star)")
                                .frame(width: 40, height: 40)
                                .background(Color.yellow.opacity(0.8))
                                .foregroundColor(Color.black)
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        
        /* DEBUG
        .onAppear {
            print("Welcome View appeared")
            print("Data counts: draws=\(dataStoreBuilder.draws.count), dates=\(dataStoreBuilder.drawDates.count)")
        }
        */
    }
    
    // MARK: - Helper Methods
    
    /// Formats and returns the date of the currently selected draw
    /// - Returns: A formatted date string, or "No data" if unavailable
    private func getDrawDate() -> String {
        // Ensure the index is valid and data exists
        guard selectedIndex >= 0, selectedIndex < dataStoreBuilder.drawDates.count else {
            return "No data"
        }
        
        // Format the date for display
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dataStoreBuilder.drawDates[selectedIndex])
    }
    
    /// Retrieves the main numbers for the currently selected draw
    /// - Returns: An array of 5 integers representing the main numbers, or placeholders if unavailable
    private func getDrawNumbers() -> [Int] {
        // Ensure the index is valid and data exists
        guard selectedIndex >= 0, selectedIndex < dataStoreBuilder.draws.count else {
            return [0, 0, 0, 0, 0]
        }
        
        // Return the first 5 numbers from the selected draw
        return Array(dataStoreBuilder.draws[selectedIndex].prefix(5))
    }
    
    /// Retrieves the star numbers for the currently selected draw
    /// - Returns: An array of 2 integers representing the star numbers, or placeholders if unavailable
    private func getDrawStars() -> [Int] {
        // Ensure the index is valid and data exists
        guard selectedIndex >= 0, selectedIndex < dataStoreBuilder.stars.count else {
            return [0, 0]
        }
        
        // Return all star numbers from the selected draw (typically 2)
        return Array(dataStoreBuilder.stars[selectedIndex])
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to the previous (older) draw by decreasing the index
    private func moveUp() {
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }
    
    /// Navigate to the next (newer) draw by increasing the index
    private func moveDown() {
        if selectedIndex < dataStoreBuilder.draws.count - 1 {
            selectedIndex += 1
        }
    }
}

// MARK: - Preview

#Preview {
    
    // Create a sample DataStoreBuilder with mock data
    let previewDataStore = DataStoreBuilder()

    // Add some preview data
    previewDataStore.draws = [[1, 5, 7, 9, 24], [3, 12, 23, 34, 45]]
    previewDataStore.stars = [[2, 5], [7, 12]]
    previewDataStore.drawDates = [Date(), Date().addingTimeInterval(-604800)]
    
    return DrawResultsView(dataStoreBuilder: previewDataStore, selectedIndex: .constant(0))
        .frame(width: 600, height: 300)
}

