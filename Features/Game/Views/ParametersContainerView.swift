//
//  ParametersContainerView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 20/03/2025.
//

import SwiftUI


//MARK: -

struct ParametersContainerView: View {
    
    // Use ObservedObject instead of StateObject since the instance is created elsewhere
    @ObservedObject var gameInstance: EuroMillionsGame
    
    // Use bindings for these values so they can be controlled from the parent
    @Binding var numberOfDraws: Int
    @Binding var selectedStrategy: DrawingStrategy
    @Binding var playerSelectedNumbers: Set<Int>
    
    // Draw algorithm selector porperties
    @State private var showingPreferredNumbersInput = false
    @State private var showingAlgorithmInfo = false
    
    // A closure for the generate action
    var generateAction: () -> Void
    
    
    // MARK: - Parameter Container
    /// Container for draw parameters
    var body: some View {
        //VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) {
        VStack(spacing: AppConfig.UI.Spacing.small) {
            
            // Title
            HStack(alignment: .center) {
                Text("Paramètres du tirage")
            }
            .font(.title2)
            
            // Number of draws
            VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) {
                // Number of draws control
                //Stepper("Nombre de Jeux à générer: \(numberOfDraws)", value: $numberOfDraws, in: 1...100)
                HStack {
                    Text("Nombre de jeux à générer:")
                        .font(.title3)
                        .padding(.leading, 25.0)
                    TextField("Enter a number", value: $numberOfDraws, format: .number)
                        .frame(width: 50, height:20)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } // end of HStack
                
                
                // Draw Algorithm selector
                HStack {
                    
                    Picker("Algorithme de tirage:  ", selection: $selectedStrategy) {
                        ForEach(DrawingStrategy.allCases) { strategy in
                            Text(strategy.rawValue).tag(strategy)
                        } // end of ForEach
                    } // end of Picker
                    
                    
                    .onChange(of: selectedStrategy) { oldValue, newValue in
                        if newValue == .userSelectedNumbers {
                            showingPreferredNumbersInput = true
                        } // end of if
                    } // end of onChange
                    
                    
                    Button {
                        showingAlgorithmInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    } // end of Button
                    
                    
                    .popover(isPresented: $showingAlgorithmInfo) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Description du tirage")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            Text(selectedStrategy == .userSelectedNumbers ?
                                 "Tirage depuis la liste de numéros sélectionnés par le joueur" :
                                    "Tirage depuis la liste des 50 numéros de la grille de l'EuroMillions")
                            .fixedSize(horizontal: false, vertical: true)
                        } // end of VStack
                        .padding()
                        .frame(width: 250)
                    } // end of popover
                    
                    Spacer()
                } // end of HStack Draw Algorithm selector
                .font(.title3)
                .padding(.horizontal, 25.0)
                .padding(.vertical, 15)
                
                
                // Filter toggles
                HStack(alignment: .top) {
                    Text("Filtres:")
                        .font(.title3)
                        .padding(.leading, 25.0)
                        .padding(.trailing, 25)
                    
                    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 15) {
                        GridRow {
                            Toggle("Doublon", isOn: $gameInstance.noDoublon)
                            Toggle("Parité", isOn: $gameInstance.isOdd)
                            Toggle("Série", isOn: $gameInstance.noSeries)
                        }
                        GridRow {
                            Toggle("Grille 5x10", isOn: $gameInstance.g5x10EvenlySplitted)
                            Toggle("Grille 10x5", isOn: $gameInstance.g10x5EvenlySplitted)
                        }
                    }
                    .fixedSize()
                    
                    Spacer()
                } // end of HStack Filters

                
                // Generate button
                Button(action: generateAction) {
                    
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Generation des jeux")
                    } // end of HStack
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(AppConfig.UI.Corner.standard)
                    
                } // end of Button Generate Action
                .disabled(gameInstance.isGenerating)
                
                if gameInstance.isGenerating {
                    ProgressView("Generating combinations...")
                } // end of If
                
            } // end of VStack
            
            .sheet(isPresented: $showingPreferredNumbersInput) {
                EuroMillionsGridNumbersSelectionView(
                    playerSelectedNumbers: $playerSelectedNumbers
                )
            }
            
        } // end of VStack
        .frame(maxWidth: .infinity)
        .padding(AppConfig.UI.Padding.small)
        
    } // end of body
    
} // end of struct

// MARK: - Preview
