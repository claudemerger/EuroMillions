///
//  DrawDistanceTable.swift
//
//  Created by Claude sur iCloud on 04/03/2025.
//

import SwiftUI


// DrawDistanceTable.swift
import SwiftUI

/// View that displays the distance table and related controls
struct DrawDistanceTable: View {
    
    // MARK: - Properties
    
    let dataStoreBuilder: DataStoreBuilder
    
    private let distanceDistribution: DistanceDistribution
    
    // Local state for this view
    @State private var percentageValue: Int = AppConfig.Analysis.standardPercentageValue
    
    // Binding for distanceMax that will be passed from parent
    @Binding var distanceMax: Int

    @State private var showDistanceChart = false
    
    // Initialization
    init(dataStoreBuilder: DataStoreBuilder, distanceMax: Binding<Int>) {
        self.dataStoreBuilder = dataStoreBuilder
        self.distanceDistribution = DistanceDistribution(
            generateDistanceTableInstance: GenerateDistanceTable()
        )
        self._distanceMax = distanceMax
    }
    /// The key is using the underscore prefix _distanceMax in the initializer, which allows you to assign a Binding<Int> to the property. This is Swift's syntax for accessing the projected value (binding) of a property wrapper.
    
    
    // Helper method to update distance max
    private func updateDistanceMaxValue() {
        guard !dataStoreBuilder.distanceTable.isEmpty else { return }
        
        let maxDistribution = distanceDistribution.generateMaxDistanceDistribution(
            table: dataStoreBuilder.distanceTable
        )
        
        distanceMax = distanceDistribution.getDistanceForPercentage(
            percentageValue,
            from: maxDistribution
        )
        
        //print("Updated distanceMax to: \(distanceMax)")
        
    } // end of func updateDistanceMaxValue
    
    // MARK: - Body
    
    var body: some View {
        // Main Column Container
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) {
                     
            // Table Container
            VStack {
                // Table Title
                Text("Table des Distances")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, AppConfig.UI.Padding.small)
                
                // Distance Table
                ScrollView {
                    LazyVStack(spacing: AppConfig.UI.Spacing.none) {
                        ForEach(0..<dataStoreBuilder.distanceTable.count, id: \.self) { index in
                            DrawRow(
                                numbers: dataStoreBuilder.distanceTable[index]
                            )
                        }
                    }
                }
                .frame(height: AppConfig.Tables.weightTableHeight)
            }
            .frame(width: AppConfig.Tables.distanceTableWidth, alignment: .leading)
            //.border(Color.black)
            
            
            // Button container
            VStack {
                Text("Graphique de la distribution des distances max des tirages")
                    .padding(AppConfig.UI.Padding.small)
                
                Button("Afficher le graphique") {
                    showDistanceChart = true
                }
                .sheet(isPresented: $showDistanceChart) {
                    DistanceChartModal(
                        distanceData: distanceDistribution.generateMaxDistanceDistribution(
                            table: dataStoreBuilder.distanceTable
                        ),
                        isPresented: $showDistanceChart
                    )
                    .interactiveDismissDisabled()
                }
            }
            .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight, alignment: .leading)
            //.border(Color.black)
            
            
            // Results Container
            VStack(alignment: .leading, spacing: 5) {
                // Title with frame width to ensure text wraps properly
                Text("Valeur de la distance max correspondant à n% des tirages")
                    .frame(width: AppConfig.UI.Container.standardWidth - 20, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, AppConfig.UI.Padding.small)
                    .padding(.top, AppConfig.UI.Padding.small)
                
                // Controls with consistent alignment
                VStack(alignment: .leading, spacing: 8) {
                    // Percentage input row
                    HStack {
                        Text("Entrer Pourcentage:")
                            .frame(width: 125, alignment: .leading)
                        
                        Spacer()
                        
                        TextField("Value", value: $percentageValue, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        
                        
                            .onChange(of: percentageValue) { _, _ in
                                updateDistanceMaxValue()
                            } // end of onChange
                        
                    } // end of HStack
                    
                    // Distance max output row
                    HStack {
                        Text("Distance max:")
                            .frame(width: 125, alignment: .leading)
                        
                        Spacer()
                        
                        TextField("Value", value: $distanceMax, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .disabled(true)
                    } // end of HStack
                    
                } // end of VStack
                .padding(.horizontal, AppConfig.UI.Padding.medium)
                .padding(.bottom, AppConfig.UI.Padding.small)
                
            } // end of Results container
            .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.minHeight, alignment: .leading)
            //.border(Color.black)
             
            Spacer()
            
        } // end of Main Column container
        
        .onAppear {
            updateDistanceMaxValue()
        } // end of onAppear
        
    } // end of body
    
} // end of struct

// MARK: - Preview
