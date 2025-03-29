//
//  AppDataService.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 27/03/2025.
//

import SwiftUI
import Combine

/// Central service that manages all app-wide data and services
/// Implemented as a true singleton to ensure consistent data access across the app
@MainActor
class AppDataService: ObservableObject {
    // MARK: - Singleton
    
    /// Shared instance for app-wide access
    static let shared = AppDataService()
    
    // MARK: - Published Properties
    
    /// The data store containing all EuroMillions data
    @Published var dataStore: DataStoreBuilder
    
    /// The drawing service for generating number combinations
    @Published var drawingService: DrawingServiceClass?
    
    /// Flag indicating if data has been fully loaded
    @Published var isDataLoaded = false
    
    /// Error message if data loading fails
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// Database builder for loading raw data
    private var databaseBuilder = DataBaseBuilder()
    
    /// Subscription cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {
        self.dataStore = DataStoreBuilder()
        
        print("🌐 AppDataService: Singleton instance created")
    }
    
    // MARK: - Public Methods
    
    /// Loads all required app data sequentially
    /// This method should be called during app startup before showing the main UI
    func loadData() async throws {
        print("🌐 AppDataService: Starting data load process")
        
        // Step 1: Load database content
        print("📊 Building database...")
        let databaseContent = try await databaseBuilder.buildDataBase()
        print("✅ Database built successfully: \(databaseContent.count) characters")
        
        // Step 2: Load data store with database content
        print("📊 Building data store...")
        try await dataStore.buildDataStore(dataBase: databaseContent)
        print("✅ Data store built successfully with \(dataStore.draws.count) draws")
        
        // Step 3: Initialize drawing service with the loaded data
        print("📊 Initializing drawing service...")
        
        await MainActor.run {
            self.drawingService = DrawingServiceClass(dataStoreBuilder: self.dataStore, verboseLogging: true)
            
            // Set loaded flag
            self.isDataLoaded = true
        }
        
        print("✅ AppDataService: All data loaded successfully")
        
        // Verify drawing service initialization
        if let service = drawingService {
            print("✅ Drawing service initialized with \(service.historicalDrawsCount) historical draws")
            
            // Test simple draw to ensure it works
            do {
                let testDraw = try service.generateDraw(strategy: .simple)
                print("✅ Test draw successful: \(testDraw)")
            } catch {
                print("❌ Test draw failed: \(error)")
                throw error
            }
        } else {
            print("❌ Drawing service initialization failed")
            throw AppError.serviceInitializationFailed
        }
    }
    
    /// Reloads all app data
    /// Can be called to refresh data during app usage
    func reloadData() async throws {
        // Reset state
        await MainActor.run {
            self.isDataLoaded = false
            self.drawingService = nil
            self.errorMessage = nil
        }
        
        // Reload all data
        try await loadData()
    }
    
    /// Returns diagnostic information about the current data state
    func getDiagnosticInfo() -> String {
        var info = "AppDataService Diagnostics:\n"
        info += "- isDataLoaded: \(isDataLoaded)\n"
        info += "- dataStore.draws count: \(dataStore.draws.count)\n"
        info += "- dataStore.sortedDraws count: \(dataStore.sortedDraws.count)\n"
        info += "- drawingService initialized: \(drawingService != nil ? "Yes" : "No")\n"
        
        if let service = drawingService {
            info += "- drawingService.historicalDrawsCount: \(service.historicalDrawsCount)\n"
        }
        
        return info
    }
}

// MARK: - App Errors

/// Custom error types for the app data service
enum AppError: Error, LocalizedError {
    case serviceInitializationFailed
    
    var errorDescription: String? {
        switch self {
        case .serviceInitializationFailed:
            return "Failed to initialize one or more app services"
        }
    }
}
