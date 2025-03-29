//
//  GameView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 12/03/2025.
//

import SwiftUI
import SwiftData


/// Main view for the EuroMillions Gaming tab
/// Displays the complete gaming module including:
/// - Game parameters including gaming algorithms and filters
/// - Game draws table
/// - Distance/Groups mapping table
/// - Gaming probabilities


import SwiftUI
import SwiftData

struct GameView: View {
    
    // MARK: - Properties
    
    /// Central data store that provides all EuroMillions draw data
    /// This is passed from the parent view through the environment
    /// Access to the centralized app data service
    @EnvironmentObject var appDataService: AppDataService

    
    // Game generation state
    @StateObject private var gameInstance: EuroMillionsGame
    @State private var numberOfDraws: Int = 10
    @State private var selectedStrategy: DrawingStrategy = .simple
    @State private var playerSelectedNumbers: Set<Int> = []
    @State private var showClearConfirmation = false
    
    init() {
        // Will be initialized properly in onAppear
        _gameInstance = StateObject(wrappedValue: EuroMillionsGame.gameInstance(
            appDataService: AppDataService.shared
        ))
    }

    @State private var showDistanceChart = false
    @State private var defaultPercentageValue = 80
    @State private var distanceMax = 0
    
    // MARK: - Body
    var body: some View {
        
        // Main container
        VStack(spacing: AppConfig.UI.Spacing.large) {
            
            // Header Container
            headerView
            
            if appDataService.dataStore.isLoading {
                ProgressView("Loading statistics...")
            } else {
                contentContainerView
            }
        }
    } // end of body
    
    // MARK: - View components
    
    //  =====================================================================
    /// Header section with EuroMillions logo and title
    private var headerView: some View {
        VStack {
            // Header section with EuroMillions logo and title
            EuroMillionsHeader()
                .frame(maxWidth: .infinity, alignment: .top)
            
            if appDataService.dataStore.hasError {
                Text(appDataService.dataStore.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(Color.blue.opacity(AppConfig.UI.Opacity.light))
        .cornerRadius(AppConfig.UI.Corner.large)
    }
    
    //  =====================================================================
    /// Main content container with left and right sections
    
    private var contentContainerView: some View {
        HStack(alignment: .top, spacing: AppConfig.UI.Spacing.small) {
            leftContainerView
            rightContainerView
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .border(Color.red, width: 1)
    }
    
    //  =====================================================================
    /// Left side container
    private var leftContainerView: some View {
        VStack {
            probabilityContainerView
            numbersMappingContainerView
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConfig.UI.Padding.small)
        .border(Color.blue, width: 1)
    }
    
    //  =====================================================================
    /// Right side container
    private var rightContainerView: some View {
        VStack(alignment: .center, spacing: AppConfig.UI.Spacing.standard) {

            parametersContainerView
            gameTableContainerView
  
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConfig.UI.Padding.small)
        .border(Color.blue, width: 1)
    }
    
    //  =====================================================================
    /// Container for win probability
    private var probabilityContainerView: some View {
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.standard) {
            WinProbability()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConfig.UI.Padding.small)
        .border(Color.black, width: 1)
    }
    
    /// Container for numbers mapping
    private var numbersMappingContainerView: some View {
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.standard) {
            // Placeholder for now
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: AppConfig.UI.Container.standardWidth, height: AppConfig.UI.Container.standardHeight)
                .border(Color.white, width: 1)
            Text("Numbers Mapping container")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppConfig.UI.Padding.small)
        .border(Color.black, width: 1)
    }
    
    //  =====================================================================
    /// Container for draw parameters
    private var parametersContainerView: some View {
        
        ParametersContainerView(
            gameInstance: gameInstance,
            numberOfDraws: $numberOfDraws,
            selectedStrategy: $selectedStrategy,
            playerSelectedNumbers: $playerSelectedNumbers,
            generateAction: generateGames
        )
    }
    
    //  =====================================================================
    /// Container for numbers mapping
    private var gameTableContainerView: some View {
        GameTableContainerView(gameInstance: gameInstance)
    }
    
    /// Game generation
    private func generateGames() {
        guard let context = try? ModelContainer(for: PersistentEuroMillionsCombination.self).mainContext else {
            return
        }
        
        Task {
            do {
                try await gameInstance.generateGames(
                    count: numberOfDraws,
                    strategy: selectedStrategy,
                    context: context
                )
            } catch {
                print("Error generating games: \(error)")
            }
        }
    }
}

// MARK: - Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(AppDataService.shared)
    }
}
