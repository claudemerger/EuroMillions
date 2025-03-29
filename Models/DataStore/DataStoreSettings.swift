//
//  DataStoreSettings.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 17/03/2025.
//

import Foundation
struct DataStoreSettings {
    
    /// Shared singleton instance of the app configuration
    static let sharedDataStoreSettings = DataStoreSettings()

    /// Public initializer to allow flexible access while maintaining singleton behavior
    public init() {
        // Initialize with default configuration
        self.fileFormatConfiguration = FileFormatConfiguration(
            separator: ";",
            dataBaseColumnMapping: dataBaseColumnMapping(
                dayColumn: 0,
                dateColumn: 1,
                ball1Column: 2,
                ball2Column: 3,
                ball3Column: 4,
                ball4Column: 5,
                ball5Column: 6,
                star1Column: 7,
                star2Column: 8,
                rapport_du_rang1Column: 9,
                rapport_du_rang2Column: 10,
                rapport_du_rang3Column: 11,
                rapport_du_rang4Column: 12,
                rapport_du_rang5Column: 13,
                rapport_du_rang6Column: 14,
                rapport_du_rang7Column: 15,
                rapport_du_rang8Column: 16,
                rapport_du_rang9Column: 17,
                rapport_du_rang10Column: 18,
                rapport_du_rang11Column: 19,
                rapport_du_rang12Column: 20,
                rapport_du_rang13Column: 21
            ),
            encoding: .utf8,
            hasHeader: true
        )
    }
    
    /// Defines the column structure for CSV files, mapping specific data points to their column indices
    ///
    /// This struct allows precise navigation of CSV file columns, ensuring correct data extraction
    struct dataBaseColumnMapping {
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
    } // end of struct dataBaseColumnMapping
    
    
    /// Specifies the file format and parsing configuration
    /// Helps in correctly reading and interpreting CSV files
    struct FileFormatConfiguration {
        /// Character used to separate columns
        let separator: String
        
        /// Mapping of columns to their specific data points
        let dataBaseColumnMapping: dataBaseColumnMapping
        
        /// Text encoding of the file
        let encoding: String.Encoding
        
        /// Whether the file includes a header row
        let hasHeader: Bool
    } // end of struct FileFormatConfiguration
    
    /// The file format configuration to use
    let fileFormatConfiguration: FileFormatConfiguration
    
} // end of struct DataStoreSettings
