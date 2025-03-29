//
//  DrawHistoryTable.swift
//
//  Created on 28/02/2025.
//


import SwiftUI

/// Table view that displays recent EuroMillions draw results
/// Shows the numbers for the most recent draws in a compact format
struct DrawHistoryTable: View {
    
    // MARK: - Properties
    
    /// Reference to the app data store containing draw data
    var dataStoreBuilder: DataStoreBuilder
    
    ///
    @State private var showSortedTable: Bool = true
    
    /// Number of draws to display in the table
    //var displayCount: Int = 100
    
    // MARK: - Computed Properties
    
    /// Returns either the regular draws or sorted draws based on toggle state
    private var drawsToDisplay: [[Int]] {
        // If showing sorted draws, use sortedDraws from appDataStore
        // Otherwise use the regular draws
        return showSortedTable ? dataStoreBuilder.sortedDraws : dataStoreBuilder.draws
    }
    
    
    // MARK: - Body
    
    var body: some View {
     
        // Main Column Container
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) {

            // Table Container
            VStack{
                // Table Title
                Text("Table des Tirages")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom,  AppConfig.UI.Padding.small)
                
                // Draw Table - ensure ScrollView doesn't add extra spacing
                ScrollView {
                    LazyVStack(spacing: AppConfig.UI.Spacing.none) { // LazyVStack for better performance
                       ForEach(0..<drawsToDisplay.count, id: \.self) { index in
                           DrawRow(
                                numbers: drawsToDisplay[index]
                            )
                        } // end of ForEach
                        
                    } // end of LazyStack
                    //.frame(width: 200, alignment: .leading)
                    
                } // end of ScrollView
                .frame(height: AppConfig.Tables.drawHistoryHeight) // Keep this height if needed for UI Container
                
            } // end of Table Container
            .frame(width: AppConfig.Tables.drawHistoryWidth, alignment: .leading)
            //.border(Color.black)
            
            
            // Buttons Container
            VStack {
                Toggle("Trier par ordre croissant" , isOn: $showSortedTable)
                    .padding(AppConfig.UI.Padding.standard)
            } // end of Buttons Container
            .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight, alignment: .leading)
            //.border(Color.black)
            
            
            // Results Container
            VStack {
                Text("Affichage: \(showSortedTable ? "par ordre croissant" : "par ordre de tirage")")
                    .font(.caption)
                    .padding(AppConfig.UI.Padding.standard)
            } // end of Results Container
            .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight,alignment: .leading)
            //.border(Color.black)
            
            Spacer()
            
        } // end of Main VStack
        //.border(Color.blue)
        
        /* DEBUG
        // Add at the top of your EuroMillionsDrawHistoryTable view's body
        .onAppear {
            print("EuroMillionsDrawHistoryTable appeared")
            print("Draws count: \(appDataStore.draws.count)")
            
            
            // Print the first few draws if available
            if !appDataStore.draws.isEmpty {
                print("First draw: \(appDataStore.draws[0])")
            } else {
                print("No draws available")
            }
        }
        */
        
    } // end of body
} // end of struct



// MARK: - Preview

struct DrawHistoryTable_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock DataStoreBuilder
        let mockDataStoreBuilder = DataStoreBuilder()
        
        // Add sample data
        mockDataStoreBuilder.draws = [
            [1, 12, 23, 39, 45],
            [3, 7, 17, 21, 50],
            [5, 11, 27, 34, 41],
            [9, 16, 29, 37, 49],
            [2, 14, 31, 42, 48],
            [1, 12, 23, 39, 45],
            [3, 7, 17, 21, 50],
            [5, 11, 27, 34, 41],
            [9, 16, 29, 37, 49],
            [2, 14, 31, 42, 48]
        ]
        
        return DrawHistoryTable(dataStoreBuilder: mockDataStoreBuilder)
            .frame(width: 400)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
}
