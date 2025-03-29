//
//  GameTableContainerView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 20/03/2025.
//

import SwiftUI

// MARK: - Game Table Container View

struct GameTableContainerView: View {
    
    //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
    @EnvironmentObject var appDataService: AppDataService
    
    
    // Use ObservedObject instead of StateObject
    @ObservedObject var gameInstance: EuroMillionsGame
    @State private var showClearConfirmation = false
    
    /*
     // Game generation state
     @StateObject private var gameInstance: EuroMillionsGame
     
     // MARK: - Properties
    @State var showClearConfirmation: Bool = false
    */
    
    // MARK: - Game Table
    /// Container for game table display
    var body: some View {
        
        VStack(alignment: .center, spacing: AppConfig.UI.Spacing.small) {
            
            Text("Table des Jeux")
                .font(.title)
                .padding(.bottom, 5)
            
            HStack {
                // Left-aligned text (leading)
                HStack {
                    Text("Nombre total de tirages effectués: ")
                    Text("\(gameInstance.drawCount)")
                        .onChange(of: gameInstance.drawCount) { oldValue, newValue in
                            print("📊 Draw count changed from \(oldValue) to \(newValue)")
                        }
                }
                
                Spacer() // This pushes the left content to the leading edge and right content to the trailing edge
                
                // Right-aligned button (trailing)
                Button(action: { showClearConfirmation = true }) {
                    Label("Corbeille", systemImage: "trash")
                        .font(.caption)
                }
                .disabled(gameInstance.loadedGames.isEmpty)
            } // end of HStack
            .padding(.horizontal)
            
            
            // Game Table : this table displays the game draws
            if gameInstance.loadedGames.isEmpty {
                Text("No combinations generated yet")
                    .foregroundColor(.secondary)
                    .padding()
                
            } else {
                
                ScrollView {
                    
                    LazyVStack(alignment: .center, spacing: AppConfig.UI.Spacing.small) {
                        
                        ForEach(Array(gameInstance.loadedGames.enumerated()), id: \.offset) { index, combination in
                            
                            HStack(spacing: 8) {
                                Text("\(index + 1).")
                                    .frame(width: 30, alignment: .trailing)
                                    .foregroundColor(.secondary)
                                
                                // Center the numbers within their parent HStack
                                HStack(spacing: 8) {
                                    ForEach(combination, id: \.self) { number in
                                        Text("\(number)")
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(16)
                                    } // end of ForEach
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } // end of HStack
                            .frame(maxWidth: 500) // Limit the width to ensure proper centering
                            .padding(.vertical, 2)
                            
                        } // end of ForEach
                        
                    } // end of LazyVStack
                    .frame(maxWidth: .infinity) // Take full width of parent
                    
                } // end of ScrollView
                .frame(maxWidth: .infinity) // Take full width of parent
            } // end of if
            
        } // end of VStack Game Table
        .frame(maxWidth: .infinity)
        .padding(AppConfig.UI.Padding.small)
        
 
            /*
            // Game Table : this table displays the game draws
            if gameInstance.loadedGames.isEmpty {
                //VStack {
                    //Spacer()
                    Text("No combinations generated yet")
                        .foregroundColor(.secondary)
                        .padding()
                    //Spacer()
                //}
                //.frame(height: 200)
                
            } else {
                
                ScrollView {
                    
                    LazyVStack(spacing: AppConfig.UI.Spacing.small) {
                        
                        ForEach(Array(gameInstance.loadedGames.enumerated()), id: \.offset) { index, combination in
                            
                            HStack {
                                Text("\(index + 1).")
                                    .frame(width: 30, alignment: .trailing)
                                    .foregroundColor(.secondary)
                                
                                ForEach(combination, id: \.self) { number in
                                    Text("\(number)")
                                        .frame(width: 32, height: 32)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(16)
                                } // end of ForEach
                                
                                Spacer()
                            } // end of HStack
                            .padding(.vertical, 2)
                            
                        } // end of ForEach
                        
                    } // end of LazyStack
                    
                } // end of ScrollView
                //.frame(maxHeight: 300)
            } // end of if
            
        } // end of VStack Game Table
        //.frame(maxWidth: .infinity)
        //.padding(AppConfig.UI.Padding.small)
        */
            
        .alert("Clear Combinations", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    await gameInstance.clearAllGames()
                }
            }
        } message: {
            Text("Are you sure you want to clear all generated combinations?")
        }
    }
    
}

//  MARK: - Preview Game Table
