//
//  WelcomeView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 16/03/2025.
//

import SwiftUI

/// Main view for the EuroMillions Results tab
/// Displays the complete results module including:
/// - Custom EuroMillions header with logo
/// - Draw results with navigation between draws
/// - Statistical analysis of draws

struct WelcomeView: View {
    
    // MARK: - Properties
    
    /// Central data store that provides all EuroMillions draw data
    /// This is passed from the parent view through the environment
    //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
    
    // Replace DataStoreBuilder with AppDataService
    @EnvironmentObject var appDataService: AppDataService
    
    /// Tracks which draw is currently selected for display and analysis
    /// Index 0 represents the most recent draw
    @State private var selectedDrawIndex: Int = 0
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            
            // Header section with EuroMillions logo and title
            EuroMillionsHeader()
            
            //
            if appDataService.dataStore.isLoading {
                // Show loading indicator
                ProgressView("Loading data...")
            } else if appDataService.dataStore.draws.isEmpty {
                // Show message when no data is available
                Text("No draw data available")
                    .foregroundColor(.secondary)
            } else {
                Text("Loaded \(appDataService.dataStore.draws.count) draws")
                // Display the selected draw with navigation controls
                DrawResultsView(
                    dataStoreBuilder: appDataService.dataStore,
                    selectedIndex: $selectedDrawIndex
                )
            } // end of if
            
                
            // Display statistical analysis of the selected draw
            /*DrawStatisticsView(
             appDataStore: appDataStore,
             selectedDrawIndex: selectedDrawIndex
             )*/
            
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Preview
#Preview {
    WelcomeView()
        .environmentObject(DataBaseBuilder())
        .environmentObject(DataStoreBuilder())
}

