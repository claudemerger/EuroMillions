//
//  CSVFieldSelector.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 16/03/2025.
//

import Foundation

/// Utility class for selecting and extracting specific fields from CSV data
/// Designed to work with the EuroMillions app's data structure and configuration
class CSVFieldSelector {
    
    /// Shared singleton instance
    static let shared = CSVFieldSelector()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Extracts selected fields from a CSV string based on the defined column mapping
    ///
    /// This function processes a raw CSV string and selects only the columns specified
    /// in the `euroMillionsFormat` column mapping, creating a new CSV string with just
    /// the required data.
    ///
    /// - Parameters:
    ///   - csvContent: The original CSV content as a string
    ///   - preserveHeader: Whether to keep the header row (if present). Default is true.
    /// - Returns: A new CSV string containing only the selected columns
    func extractSelectedFields(from csvContent: String, preserveHeader: Bool = true) -> String {
        // Get the app configuration
        let appConfig = DataBaseSettings.sharedDataBaseSettings
        let formatConfig = appConfig.euroMillionsFormat
        
        // Split the CSV content into lines
        let lines = csvContent.components(separatedBy: .newlines)
        guard !lines.isEmpty else { return "" }
        
        // Prepare a new array to store selected content
        var selectedContent: [String] = []
        
        // Get all columns we want to extract based on the column mapping
        let sourceColumnMapping = formatConfig.sourceColumnMapping
        let columnsToExtract = [
            sourceColumnMapping.dayColumn,
            sourceColumnMapping.dateColumn,
            sourceColumnMapping.ball1Column,
            sourceColumnMapping.ball2Column,
            sourceColumnMapping.ball3Column,
            sourceColumnMapping.ball4Column,
            sourceColumnMapping.ball5Column,
            sourceColumnMapping.star1Column,
            sourceColumnMapping.star2Column,
            sourceColumnMapping.rapport_du_rang1Column,
            sourceColumnMapping.rapport_du_rang2Column,
            sourceColumnMapping.rapport_du_rang3Column,
            sourceColumnMapping.rapport_du_rang4Column,
            sourceColumnMapping.rapport_du_rang5Column,
            sourceColumnMapping.rapport_du_rang6Column,
            sourceColumnMapping.rapport_du_rang7Column,
            sourceColumnMapping.rapport_du_rang8Column,
            sourceColumnMapping.rapport_du_rang9Column,
            sourceColumnMapping.rapport_du_rang10Column,
            sourceColumnMapping.rapport_du_rang11Column,
            sourceColumnMapping.rapport_du_rang12Column,
            sourceColumnMapping.rapport_du_rang13Column
        ]
        
        // Process each line
        for (index, line) in lines.enumerated() {
            // Skip empty lines
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            // Handle header row if present
            if index == 0 && formatConfig.hasHeader && !preserveHeader {
                continue
            }
            
            // Split the line into fields
            let separator = formatConfig.separator
            let fields = line.components(separatedBy: separator)
            
            // Check if we have enough fields
            guard fields.count > columnsToExtract.max() ?? 0 else {
                print("⚠️ Warning: Line has fewer fields than expected: \(line)")
                continue
            }
            
            // Select only the fields we want
            var selectedFields: [String] = []
            for columnIndex in columnsToExtract {
                if columnIndex >= 0 && columnIndex < fields.count {
                    selectedFields.append(fields[columnIndex])
                } else {
                    // Add an empty field if the index is out of bounds
                    selectedFields.append("")
                }
            }
            
            // Join the selected fields and add to our result
            selectedContent.append(selectedFields.joined(separator: separator))
        }
        
        // Join all lines and return
        return selectedContent.joined(separator: "\n")
    }
    
    
    /// Creates a new CSV with only specified columns
    ///
    /// - Parameters:
    ///   - csvContent: Original CSV content
    ///   - columnIndices: Array of column indices to extract (1-based indexing)
    ///   - separator: CSV field separator
    ///   - preserveHeader: Whether to keep the header row
    /// - Returns: New CSV string with only selected columns
    func extractCustomColumns(
        from csvContent: String,
        columnIndices: [Int],
        separator: String = ";",
        preserveHeader: Bool = true
    ) -> String {
        // Split the CSV content into lines
        let lines = csvContent.components(separatedBy: .newlines)
        guard !lines.isEmpty else { return "" }
        
        // Prepare a new array to store selected content
        var selectedContent: [String] = []
        
        // Process each line
        for (index, line) in lines.enumerated() {
            // Skip empty lines
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            // Handle header row if present
            if index == 0 && !preserveHeader {
                continue
            }
            
            // Split the line into fields
            let fields = line.components(separatedBy: separator)
            
            // Check if we have enough fields for at least some columns
            if fields.count < columnIndices.min() ?? 1 {
                print("⚠️ Warning: Line has fewer fields than minimum required: \(line)")
                continue
            }
            
            // Select only the fields we want
            var selectedFields: [String] = []
            for columnIndex in columnIndices {
                // Make sure the index is valid
                if columnIndex >= 0 && columnIndex < fields.count {
                    selectedFields.append(fields[columnIndex])
                } else {
                    // Add an empty field if the index is out of bounds
                    selectedFields.append("")
                }
            }
            
            // Join the selected fields and add to our result
            selectedContent.append(selectedFields.joined(separator: separator))
        }
        
        // Join all lines and return
        return selectedContent.joined(separator: "\n")
    }
}
