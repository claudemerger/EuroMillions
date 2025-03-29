//
//  TabView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 15/03/2025.
//


import SwiftUI

/// Main tabbed container view for the EuroMillions application
/// Provides navigation between different functional modules:
/// - Results: Shows EuroMillions draw results and analysis
/// - Statistics: Will provide detailed statistical analysis (upcoming in v0.2)
/// - Pick Numbers: Will provide number generation tools (upcoming)
/// - Analysis: Will provide advanced draw pattern analysis (upcoming)

struct EuroMillionsTabView: View {
    // MARK: - Properties
    
    /// Access to the centralized app data service
    @EnvironmentObject var appDataService: AppDataService

    /// Tracks which tab is currently selected
    /// Default is 0 (Results tab)
    @State private var selectedTab = 0
    
    // MARK: - View Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            //WelcomePlaceholderView()
            WelcomeView()
            //DataVerificationView()
            //.environmentObject(dataStoreBuilder)
                .tabItem {
                    Label("Welcome", systemImage: "tablecells")
                }
                .tag(0)
            
            // Statistics Tab - Placeholder for v0.2
            //StatisticsPlaceholderView()
            StatisticsView()
            //.environmentObject(appDataStore)
                .tabItem {
                    Label("Statistiques", systemImage: "chart.bar")
                }
                .tag(1)
            
            // Number Picker Tab - Placeholder for future version
            GameView()
            //NumberPickerPlaceholderView()
            //.environmentObject(appDataStore)
                .tabItem {
                    Label("Jouer", systemImage: "dice")
                }
                .tag(2)
            
            // Analysis Tab - Placeholder for future version
            AnalysisPlaceholderView()
            //.environmentObject(appDataStore)
                .tabItem {
                    Label("Backtest", systemImage: "magnifyingglass")
                }
                .tag(3)
            
            
            // Add this to your TabView in EuroMillionsTabView.swift
            //DataVerificationView()
            DeveloperToolsView()
                .tabItem {
                    Label("Developer Tools", systemImage: "checkmark.circle")
                }
                .tag(4) // or whatever your next available tag is
        }
        
        .onAppear {
            print("🚀 TabView appeared with AppDataService")
            
            // Log diagnostic info
            print(appDataService.getDiagnosticInfo())
        }
        
    } // end of TabView
    
    
    // MARK: - Placeholder Views
    
    /// Placeholder view for the Welcome tab
    struct WelcomePlaceholderView: View {
        
        // Access environment objects if needed
        //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
        @EnvironmentObject var appDataService: AppDataService
        
        var body: some View {
            VStack(spacing: 20) {
                // Icon representing statistics functionality
                Image(systemName: "tablecells")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                // Module title
                Text("Welcome Module")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Version information
                Text("Coming in v0.1")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // Description of planned functionality
                Text("This module will display the draws of the lottery.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    /// Placeholder view for the Statistics tab
    /// Will be replaced with actual implementation in v0.2
    struct StatisticsPlaceholderView: View {
        
        // Access environment objects if needed
        //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
        @EnvironmentObject var appDataService: AppDataService
        
        var body: some View {
            VStack(spacing: 20) {
                // Icon representing statistics functionality
                Image(systemName: "chart.bar")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                // Module title
                Text("Statistics Module")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Version information
                Text("Coming in v0.2")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // Description of planned functionality
                Text("This module will provide detailed statistical analysis of EuroMillions draws.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    /// Placeholder view for the Number Picker tab
    /// Will be implemented in a future version
    struct NumberPickerPlaceholderView: View {
        
        // Access environment objects if needed
        //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
        @EnvironmentObject var appDataService: AppDataService
        
        var body: some View {
            VStack(spacing: 20) {
                // Icon representing number picking functionality
                Image(systemName: "dice")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                // Module title
                Text("Number Picker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Version information
                Text("Coming soon")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                // Description of planned functionality
                Text("This module will help you generate and select EuroMillions numbers.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
        }
    }
}


/// Placeholder view for the Analysis tab
/// Will be implemented in a future version
struct AnalysisPlaceholderView: View {
    
    // Access environment objects if needed
    //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
    @EnvironmentObject var appDataService: AppDataService
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon representing analysis functionality
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            // Module title
            Text("Draw Analysis")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Version information
            Text("Coming soon")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Description of planned functionality
            Text("This module will provide in-depth analysis of draw patterns and trends.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}




// MARK: - Preview

#Preview {
    EuroMillionsTabView()
        .environmentObject(AppDataService.shared)
}

/*
#Preview {
    EuroMillionsTabView()
        .environmentObject(DataStoreBuilder())
        .environmentObject(DataBaseBuilder())
}
*/
