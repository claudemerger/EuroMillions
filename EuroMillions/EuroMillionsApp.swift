//
//  EuroMillionsApp.swift
//  EuroMillions
//
//  Created on 24/03/2025.
//

import SwiftUI

/// @main attribute marks this struct as the entry point of the application
@main
struct EuroMillionsApp: App {
    // MARK: - Properties
    
    /// The shared app data service that manages all data and services
    @StateObject private var appDataService = AppDataService.shared
    
    /// Stores any error that occurs during the data loading process
    @State private var loadingError: Error?
    
    // MARK: - Body
    
    /// Defines the app's window and root view structure
    var body: some Scene {
        WindowGroup {
            if appDataService.isDataLoaded {
                // Only show the main UI after data is loaded successfully
                EuroMillionsTabView()
                    // Inject the app data service into the environment
                    // This makes it accessible to all child views
                    .environmentObject(appDataService)
            } else {
                // Show loading screen until data is ready or an error occurs
                LoadingView(error: loadingError)
                    .onAppear {
                        // Start loading data when the loading view appears
                        Task {
                            await loadAppData()
                        }
                    }
            }
        }
    }
    
    // MARK: - Functions
    
    /// Asynchronously loads all application data through the app data service
    private func loadAppData() async {
        print("🔄 Starting loadAppData()")
        do {
            print("🚀 EuroMillionsApp: Loading application data via AppDataService...")
            
            // Load all data through the centralized service
            try await appDataService.loadData()
            
            print("✅ EuroMillionsApp: All data loaded successfully")
            
        } catch {
            // Handle and log any errors that occur during data loading
            print("❌ EuroMillionsApp: Error loading data: \(error)")
            loadingError = error
            
            // Store error in app data service too for reference elsewhere
            await MainActor.run {
                appDataService.errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Loading View

/// View displayed during the application's data loading process
/// Also handles displaying errors and providing retry functionality
struct LoadingView: View {
    /// Optional error passed from the main app if data loading fails
    var error: Error?
    
    var body: some View {
        VStack(spacing: 20) {
            if error == nil {
                // Loading state - show spinner and message
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Loading EuroMillions Data...")
                    .font(.headline)
            } else {
                // Error state - show error icon, message and retry button
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Error Loading Data")
                    .font(.headline)
                
                Text(error?.localizedDescription ?? "Unknown error")
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Retry button to attempt loading data again
                Button("Retry") {
                    Task {
                        await loadAppData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
    
    /// This is a placeholder function that doesn't actually do anything
    /// The real implementation is in the EuroMillionsApp struct
    /// This is called when the user clicks the retry button
    private func loadAppData() async {
        // This doesn't do anything - the actual implementation is in EuroMillionsApp
    }
}


/*
import SwiftUI

/// @main attribute marks this struct as the entry point of the application
@main
struct EuroMillionsApp: App {
    // MARK: - Properties
    
    /// DataBaseBuilder instance that handles creation and management of the app's database
    /// @StateObject ensures this persists for the lifetime of the app and only initializes once
    @StateObject private var dataBaseBuilder = DataBaseBuilder()
    
    /// DataStoreBuilder instance that manages the app's data storage layer
    /// @StateObject ensures this persists for the lifetime of the app and only initializes once
    @StateObject private var dataStoreBuilder = DataStoreBuilder()
    
    /// The drawing service instance - initialized after data is loaded
    //@State private var drawingService: DrawingServiceClass?
    
    /// Flag to track whether the application data has been loaded successfully
    /// Controls whether to show the main UI or the loading screen
    @State private var isDataLoaded = false
    
    /// Stores any error that occurs during the data loading process
    /// Used to display error information in the LoadingView
    @State private var loadingError: Error?
    
    // MARK: - Body
    
    /// Defines the app's window and root view structure
    var body: some Scene {
        WindowGroup {
            if isDataLoaded {
                // Only show the main UI after data is loaded successfully
                EuroMillionsTabView()
                // Inject the data manager instances into the environment
                    // This makes them accessible to all child views
                    .environmentObject(dataStoreBuilder)
                    .environmentObject(dataBaseBuilder)
                
            } else {
                // Show loading screen until data is ready or an error occurs
                LoadingView(error: loadingError)
                    .onAppear {
                        // Start loading data when the loading view appears
                        Task {
                            await loadAppData()
                        }
                    }
            }
        }
    }
    
    // MARK: - Functions
    
    /// Asynchronously loads all application data in sequence
    /// This method coordinates the initialization of both the database and data store
    private func loadAppData() async {
        print("🔄 Starting loadAppData()")
        do {
            print("🚀 EuroMillionsApp: Loading application data...")
            
            // Step 1: Build the database first
            print("📊 Building database...")
            let databaseContent = try await dataBaseBuilder.buildDataBase()
            print("✅ Database built successfully: \(databaseContent.count) characters")
            
            // Step 2: Use the database output to initialize the data store
            print("📊 Building data store...")
            try await dataStoreBuilder.buildDataStore(dataBase: databaseContent)
            print("✅ Data store built successfully with \(dataStoreBuilder.draws.count) draws")
            
            // Print diagnostics to confirm data is loaded
            print("📊 Data Store Diagnostics after loading:")
            dataStoreBuilder.printDiagnostics()
            
            // Step 3: Update UI state to show the main application
            print("🏁 Setting isDataLoaded to true")
            isDataLoaded = true
            
        } catch {
            // Handle and log any errors that occur during data loading
            print("❌ EuroMillionsApp: Error loading data: \(error)")
            loadingError = error
        }
    }
}

// MARK: - Loading View

/// View displayed during the application's data loading process
/// Also handles displaying errors and providing retry functionality
struct LoadingView: View {
    /// Optional error passed from the main app if data loading fails
    var error: Error?
    
    var body: some View {
        VStack(spacing: 20) {
            if error == nil {
                // Loading state - show spinner and message
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Loading EuroMillions Data...")
                    .font(.headline)
            } else {
                // Error state - show error icon, message and retry button
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Error Loading Data")
                    .font(.headline)
                
                Text(error?.localizedDescription ?? "Unknown error")
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Retry button to attempt loading data again
                Button("Retry") {
                    Task {
                        await loadAppData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
    
    /// This is a placeholder function that doesn't actually do anything
    /// The real implementation is in the EuroMillionsApp struct
    /// This is called when the user clicks the retry button
    private func loadAppData() async {
        // This doesn't do anything - the actual implementation is in EuroMillionsApp
    }
}
*/
