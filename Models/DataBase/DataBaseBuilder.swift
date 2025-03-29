//
//  DataManager.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 16/03/2025.
//

/// `DataManager` is responsible for coordinating the entire data processing pipeline for EuroMillions lottery data.
///
/// The class manages the complex workflow of:
/// - Downloading current lottery draw data
/// - Parsing current and historical data
/// - Merging different data sources
/// - Handling the sequential flow of data processing operations
///
/// - Note: This class is designed to be used on the main actor to ensure thread-safe operations
/// - Important: All methods are asynchronous to handle potential network and file I/O operations
///
import Foundation


@MainActor
class DataBaseBuilder: ObservableObject {
    
    // MARK: - Private Properties
    
    /// Handles downloading of game data from external sources
    private let dataDownloader: DataDownloader
    
    /// Provides access to and management of historical lottery draw data
    private let historicalManager: HistoricalDataManager
    
    // MARK: - Initialization
    
    /// Initializes a new DataManager instance with default components
    ///
    /// This initializer sets up all necessary components for the data processing pipeline:
    /// - DataDownloader for fetching new data
    /// - DataParser for converting raw data to structured formats
    /// - DataMerger for combining different data sets
    /// - HistoricalDataManager for handling historical data
    init() {
        self.dataDownloader = DataDownloader()
        self.historicalManager = HistoricalDataManager()
        
        // Uncomment for debugging
        //print("✅ DataManager: Initialization complete")
    }
    
    // MARK: - Public Methods
    
    /// Orchestrates the entire data processing workflow
    ///
    /// This method performs a series of operations:
    /// 1. Download current EuroMillions draw data
    /// 2. Parse the current data
    /// 3. Load historical data from bundle
    /// 4. Parse historical data
    /// 5. Merge current and historical datasets
    ///
    /// - Returns:
    /// - Throws: Errors that occur during downloading, parsing, or merging processes
    
    public func buildDataBase() async throws -> String {
        // Uncomment for detailed logging
        //print("🔄 function: buildDataBase: Start loading data...")
                
        // Step 1: Download euroMillions current data from web site
        //print("📥 DataManager: Start downloading current data ...")
        let currentFDJ_CSVContent = try await dataDownloader.downloadGameData(for: "euromillions")
        //print("✅ buildDataBase: Download complete")
        //print("downloaded csv file : \(currentFDJ_CSVContent)")
        
        // Extract only the fields we need using our utility class
        let currentCSVContent = CSVFieldSelector.shared.extractSelectedFields(from: currentFDJ_CSVContent)
        //print("✅ buildDataBase: Selected fields extracted")
        
        /*
        // Print a sample of the extracted content for debugging
        let sampleLines1 = currentCSVContent.components(separatedBy: .newlines).prefix(3)
        print("Sample of extracted content:")
        for line in sampleLines1 {
            print(line)
        }
        */
       
        // Step2 : Load historical data
        //print("📥 buildDataBase: Loading historical data...")
        let historicalManager = HistoricalDataManager()
        let historicalCSVContent = try await historicalManager.loadHistoricalData()
        //print("✅ buildDataBase: Historical data loaded")

        /*
        // Print a sample of the extracted content for debugging
        let sampleLines2 = historicalCSVContent.components(separatedBy: .newlines).prefix(3)
        print("Sample of extracted content:")
        for line in sampleLines2 {
            print(line)
        }
        */
        
       
        // Step 3: Concatenate the data
        // First, check if both CSVs have headers
            let currentCSVLines = currentCSVContent.components(separatedBy: .newlines)
            let historicalCSVLines = historicalCSVContent.components(separatedBy: .newlines)
            
            var mergedCSVContent = ""
            
            // If current data has a header, we'll keep it and skip the header from the historical data
            if !currentCSVLines.isEmpty && !historicalCSVLines.isEmpty {
                // Get the app configuration to check if CSVs have headers
                let appConfig = DataBaseSettings.sharedDataBaseSettings
                let hasHeader = appConfig.euroMillionsFormat.hasHeader
                
                if hasHeader {
                    // Add the historical data (including header)
                    mergedCSVContent = currentCSVContent
                    
                    // Add current data (excluding header)
                    if historicalCSVLines.count > 1 {
                        // Get all lines except the header
                        let historicalDataWithoutHeader = historicalCSVLines[1...].joined(separator: "\n")
                        
                        // Add a newline between datasets if historical data doesn't end with one
                        if !mergedCSVContent.hasSuffix("\n") {
                            mergedCSVContent += "\n"
                        }
                        
                        // Append the current data without its header
                        mergedCSVContent += historicalDataWithoutHeader
                    }
                } else {
                    // If no headers, simply concatenate with a newline in between
                    mergedCSVContent = currentCSVContent
                    
                    // Add a newline between datasets if historical data doesn't end with one
                    if !mergedCSVContent.hasSuffix("\n") {
                        mergedCSVContent += "\n"
                    }
                    
                    // Append current data
                    mergedCSVContent += historicalCSVContent
                }
            } else if !currentCSVLines.isEmpty {
                // If only current data exists
                mergedCSVContent = currentCSVContent
            } else if !historicalCSVLines.isEmpty {
                // If only current data exists
                mergedCSVContent = historicalCSVContent
            }
            
            //print("✅ DataManager: Data concatenation complete")
            
            /*
            // Print a sample of the merged content for debugging
            let sampleLines = mergedCSVContent.components(separatedBy: .newlines).prefix(3)
            print("Sample of merged content (first 3 lines):")
            for line in sampleLines {
                print(line)
            }
            */
            
            // Optionally, you might want to save the merged CSV for future use
            saveToFile(csvContent: mergedCSVContent, filename: "euromillions_database.csv")
            
            // For now, just return the dataBase array
            // In a real implementation, you might parse this merged data further
        return mergedCSVContent
        }
}

// MARK: - Helper
// Optional: Add a helper method to save the concatenated data
private func saveToFile(csvContent: String, filename: String) {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("❌ Could not access documents directory")
        return
    }
    
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    do {
        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        //print("✅ Successfully saved merged data to: \(fileURL.path)")
    } catch {
        print("❌ Failed to save merged data: \(error)")
    }
}
