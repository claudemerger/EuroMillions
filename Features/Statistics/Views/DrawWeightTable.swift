//
//  DrawWeightTable.swift
//
//  Created by Claude sur iCloud on 05/03/2025.
//

import SwiftUI
//


import SwiftData


// MARK: - Structure DrawWeightTable
/// `DrawWeightTable` is a SwiftUI view that displays a table showing the frequency of drawn lottery
/// numbers within a configurable distance parameter.
///
/// The view shows:
/// - A table of occurrence counts for each number in historical draws
/// - Distribution information visualizing the occurrence patterns
/// - Summary statistics about the data
///
/// The view dynamically updates when the `distanceMax` parameter changes.
        
    // MARK: - Properties

struct DrawWeightTable: View {
    // Add this state variable to force refreshes
     @State private var refreshID = UUID()

    let dataStoreBuilder: DataStoreBuilder
        
    @Binding var distanceMax: Int
    
    
    // MARK: - Methods
    /// Updates the weight table data based on the current `distanceMax` value.
    /// This recalculates the entire occurrence table using the `GenerateWeightTable` utility.
    /// After calculation, it forces a UI refresh by updating the `refreshID` UUID.
    ///
    /// - Throws: Any errors from the underlying calculation are caught and logged.
    
    private func updateData() {
        
        //print("update weight table with distance: \(distanceMax)")
        do {
            dataStoreBuilder.weightTable = try GenerateWeightTable.calculateNumberWeight(table: dataStoreBuilder.draws, distance: distanceMax)
            // Force refresh by updating refresh ID
            self.refreshID = UUID()
            //print("Weight table updated with \(dataStoreBuilder.weightTable.count) rows")
        } catch {
            print("Error calculating weight table: \(error)")
        }
    }
    
    
    
    // MARK: - Body
    /// Constructs the view hierarchy for the weight table and related components.
    ///
    /// The layout includes:
    /// - A scrollable table showing occurrence counts for each draw
    /// - A section showing distribution statistics
    /// - A visualization of the distribution pattern
    ///
    /// The view automatically refreshes when `distanceMax` changes or when the view appears.
    
    var body: some View {
        
        // Main Column container
        VStack (spacing: AppConfig.UI.Spacing.standard) {
            
            VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) {
                
                // Table Container
                VStack {
                    // Table Title
                    Text("Table des Goupes")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.bottom, AppConfig.UI.Padding.small)
                    
                    // Weight Table
                    ScrollView {
                        LazyVStack(spacing: AppConfig.UI.Spacing.none) {
                            ForEach(0..<dataStoreBuilder.weightTable.count, id: \.self) { index in
                                DrawRow(
                                    numbers: dataStoreBuilder.weightTable[index]
                                )
                                
                                .id("\(refreshID)-\(index)") // Add a unique ID that changes with refreshes
                                
                            } // end of ForEach
                            
                        } // end of LazyStack
                        
                    } // end of WeightTable
                    .frame(height: AppConfig.Tables.weightTableHeight)
                    
                } // end of Table container
                .frame(width: AppConfig.Tables.distanceTableWidth, alignment: .leading)
                //.border(Color.black)
                 
                // Button container
                VStack( alignment: .center) {
                    Text("Distribution des groupes")
                        .padding(AppConfig.UI.Padding.small)
                    
                    Text("Rows: \(dataStoreBuilder.weightTable.count) \n Id: \(refreshID)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }  // end of button container
                .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight, alignment: .leading)
                //.border(Color.black)
                
                
                // Results Container
                VStack(alignment: .leading, spacing: 5) {
                    Text("Groupe")
                        .padding(.top, 10)
                        .foregroundColor(.blue)
                    
                    DistributionArrayView(distribution: generateDistributionArrayFromArray(from: dataStoreBuilder.weightTable))
                        .padding(.vertical,2)
                        .frame(height: 35)
                    
                    Text("Nombre d'occurences")
                        .padding(.top, 0)
                        .foregroundColor(.blue)
                    
                } // end of Results container
                .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight, alignment: .leading)
                //.border(Color.black)
                
                Spacer()
                
                    .id(refreshID) // This forces a complete redraw when refreshID changes
                    .onAppear {
                        //print("displaying initial view")
                        updateData()
                    } // end of onAppear
                
                    .onChange(of: distanceMax) { oldValue, newValue in
                        //print("DistanceMax changed from \(oldValue) to \(newValue)")
                        updateData()
                    }
            }
        } // end of Main column container
    } //  end of body
} // end of struct

