//
//  DrawingSelectorView.swift
//  Loto
//
//  Created by Claude sur iCloud on 25/11/2024.
//

import SwiftUI
import Combine

/// Main selector class that manages different drawing services and strategies
/// Acts as a coordinator between UI and the various drawing algorithms
@MainActor
class DrawingSelectorViewClass: ObservableObject {
    // MARK: - Properties
    
    /// The drawing service that handles number generation
    @Published private(set) var drawingService: DrawingServiceClass?
    
    /// Property to access the drawing service for backward compatibility
    public var drawingServiceInstance: DrawingServiceClass? {
        return drawingService
    }
    
    /// Selected drawing strategy
    @Published var selectedStrategy: DrawingStrategy = .simple
    
    /// Current generated numbers
    @Published var generatedNumbers: [Int] = []
    
    /// Status message for UI feedback
    @Published var statusMessage: String = "Ready to generate"
    
    /// Error message if generation fails
    @Published var errorMessage: String? = nil
    
    /// Flag indicating if a draw is in progress
    @Published var isGenerating: Bool = false
    
    /// Flag indicating if the service is ready
    @Published var isServiceReady: Bool = false
    
    /// Verbose logging flag
    private let verboseLogging: Bool
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(verboseLogging: Bool = false) {
        self.verboseLogging = verboseLogging
        
        if verboseLogging {
            print("🎲 DrawingSelectorViewClass initialized")
        }
    }
    
    // MARK: - Public Methods
    
    // Initializes the drawing services with the fully loaded data store
    /// This should be called from the TabView after data is loaded
    ///
    func initializeServices(dataStoreBuilder: DataStoreBuilder, verboseLogging: Bool = false) {
        if self.verboseLogging || verboseLogging {
            print("🎲 DrawingSelectorViewClass.initializeServices(dataStoreBuilder:) called")
            print("📊 dataStoreBuilder has \(dataStoreBuilder.draws.count) draws")
            print("📊 dataStoreBuilder has \(dataStoreBuilder.sortedDraws.count) sorted draws")
        }
        
        // Skip initialization if dataStoreBuilder is empty
        if dataStoreBuilder.draws.isEmpty {
            print("⚠️ DrawingSelectorViewClass: Cannot initialize with empty dataStoreBuilder")
            return
        }
        
        // Skip initialization if already initialized
        if self.drawingService != nil {
            print("ℹ️ DrawingSelectorViewClass: Drawing service already initialized")
            return
        }
        
        // Initialize the drawing service with the data store
        DispatchQueue.main.async {
            // Create the drawing service
            self.drawingService = DrawingServiceClass(
                dataStoreBuilder: dataStoreBuilder,
                verboseLogging: self.verboseLogging || verboseLogging
            )
            
            // Set the ready flag
            self.isServiceReady = true
            
            // Verify initialization
            if self.drawingService != nil {
                if self.verboseLogging || verboseLogging {
                    print("✅ DrawingSelectorViewClass: DrawingService initialized with \(dataStoreBuilder.draws.count) draws")
                }
            } else {
                print("❌ DrawingSelectorViewClass: Failed to initialize DrawingService")
            }
        }
    }
    
    /// Generates a draw using the selected strategy
    func generateDraw(dataStoreBuilder: DataStoreBuilder? = nil) {
        // Reset status
        isGenerating = true
        errorMessage = nil
        statusMessage = "Generating numbers..."
        
        if verboseLogging {
            print("🎲 DrawingSelectorViewClass.generateDraw called")
            print("🎲 Selected strategy: \(selectedStrategy)")
        }
        
        // Check if we have a service
        if drawingService == nil {
            // If a data store was provided, try to initialize the service
            if let dataStore = dataStoreBuilder {
                if verboseLogging {
                    print("🎲 No drawing service, initializing with provided dataStore")
                }
                
                // Initialize the service with the provided data store
                self.drawingService = DrawingServiceClass(
                    dataStoreBuilder: dataStore,
                    verboseLogging: self.verboseLogging
                )
                
                isServiceReady = true
            } else {
                // No service and no data store provided
                errorMessage = "Drawing service not initialized"
                statusMessage = "Error: service not ready"
                isGenerating = false
                return
            }
        }
        
        do {
            // Generate the draw
            guard let service = drawingService else {
                throw GameError.algorithmNotInitialized
            }
            
            if verboseLogging {
                print("🎲 Calling service.generateDraw with strategy: \(selectedStrategy)")
            }
            
            // Generate the numbers
            generatedNumbers = try service.generateDraw(strategy: selectedStrategy)
            
            // Update status
            statusMessage = "Numbers generated successfully"
            
            if verboseLogging {
                print("✅ Generated numbers: \(generatedNumbers)")
            }
            
        } catch {
            // Handle errors
            errorMessage = error.localizedDescription
            statusMessage = "Error generating numbers"
            
            if verboseLogging {
                print("❌ Error generating draw: \(error)")
            }
        }
        
        // Update status
        isGenerating = false
    }
}
