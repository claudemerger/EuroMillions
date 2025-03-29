//
//  DataBaseSettings.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 17/03/2025.
//

import Foundation

/// Provides constant paths for different resources in the application
struct Paths {
    /// Filename for historical EuroMillions data (without file extension)
    static let euroMillionsHistoricalData = "EuroMillionsHistoricalData"
}


/// Defines the configuration for data source retrieval
/// Provides details about where and how to fetch game data
struct DataSourceConfiguration {
    /// Base URL for the data source
    let baseURL: String
    
    /// Specific endpoint path for data retrieval
    let endpointPath: String
    
    /// How frequently the data should be updated (in seconds)
    let updateFrequency: TimeInterval
    
    /// Format of the data file
    let fileFormat: String
    
    /// Compression type of the file (if any)
    let compression: String?
}

///
struct DataBaseSettings {
    
    /// Shared singleton instance of the app configuration
    static let sharedDataBaseSettings = DataBaseSettings()
    
    /// Public initializer to allow flexible access while maintaining singleton behavior
    public init() {}
    
    
    // MARK: - Data Source Configurations
    
    /// Retrieves the path to historical EuroMillions data
    /// - Returns: Full path to the consolidated historical data CSV file
    /// - Throws: Fatal error if the historical data file is not found in the main bundle
    var historicalPath: String {
        if let bundlePath = Bundle.main.path(forResource: "euromillions_consolidated", ofType: "csv") {
            return bundlePath
        }
        fatalError("Historical data file not found in bundle")
    }
    
    /// Configuration for retrieving current EuroMillions data
    let fdjDataSource = DataSourceConfiguration(
        baseURL: "https://www.sto.api.fdj.fr",
        endpointPath: "/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afe6",
        updateFrequency: 86400, // 24 hours in seconds
        fileFormat: "csv",
        compression: "zip"
    )

    
    // MARK: - File Format Configurations
    /// Defines the structure of the raw FDJ file
    struct FileFormatConfiguration {
        /// Character used to separate columns
        let separator: String
        
        /// Mapping of columns to their specific data points
        let sourceColumnMapping: SourceColumnMapping
        
        /// Text encoding of the file
        let encoding: String.Encoding
        
        /// Whether the file includes a header row
        let hasHeader: Bool
    } // end of struct FileFormatConfiguration
    
    
    /// Defines the column structure for CSV files, mapping specific data points to their column indices
    /// This struct allows precise navigation of CSV file columns, ensuring correct data extraction
    struct SourceColumnMapping {
        /// Column index for the day of the draw
        let dayColumn: Int
        
        /// Column index for the date of the draw
        let dateColumn: Int
        
        /// Column indices for the 5 main ball numbers
        let ball1Column: Int
        let ball2Column: Int
        let ball3Column: Int
        let ball4Column: Int
        let ball5Column: Int
        
        /// Column indices for the 2 star numbers
        let star1Column: Int
        let star2Column: Int
        
        /// Column indices for various prize rank winnings
        let rapport_du_rang1Column: Int
        let rapport_du_rang2Column: Int
        let rapport_du_rang3Column: Int
        let rapport_du_rang4Column: Int
        let rapport_du_rang5Column: Int
        let rapport_du_rang6Column: Int
        let rapport_du_rang7Column: Int
        let rapport_du_rang8Column: Int
        let rapport_du_rang9Column: Int
        let rapport_du_rang10Column: Int
        let rapport_du_rang11Column: Int
        let rapport_du_rang12Column: Int
        let rapport_du_rang13Column: Int
    } // end of struct SourceColumnMapping
    
    
    /// Defines the file format for the original EuroMillions FDJ data file ( just the fields we are interested in)
    let euroMillionsFormat = FileFormatConfiguration(
        separator: ";",
        sourceColumnMapping: SourceColumnMapping(
            dayColumn: 1,
            dateColumn: 2,
            ball1Column: 5,
            ball2Column: 6,
            ball3Column: 7,
            ball4Column: 8,
            ball5Column: 9,
            star1Column: 10,
            star2Column: 11,
            rapport_du_rang1Column: 16,
            rapport_du_rang2Column: 19,
            rapport_du_rang3Column: 22,
            rapport_du_rang4Column: 25,
            rapport_du_rang5Column: 28,
            rapport_du_rang6Column: 31,
            rapport_du_rang7Column: 34,
            rapport_du_rang8Column: 37,
            rapport_du_rang9Column: 40,
            rapport_du_rang10Column: 43,
            rapport_du_rang11Column: 46,
            rapport_du_rang12Column: 49,
            rapport_du_rang13Column: 52
        ),
        encoding: .utf8,
        hasHeader: true
    )
    
} // end of struct DataBaseSettings
