//
//  HistoricalDataManager.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 16/03/2025.
//


import Foundation

actor HistoricalDataManager {
    
    enum StorageError: Error {
        case fileNotFound
        case fileReadError
    }
    
    func loadHistoricalData() async throws -> String {
        guard let csvURL = Bundle.main.url(forResource: "EuroMillionsHistoricalData",
                                             withExtension: "csv") else {
            print("❌ Failed to find CSV file in bundle")  // Add debug print
            throw StorageError.fileNotFound
        }
        
        do {
            let content = try String(contentsOf: csvURL, encoding: .utf8)
            //print("✅ Successfully loaded CSV file")  // Add debug print
            return content
        } catch {
            print("❌ Error reading CSV file: \(error)")  // Add debug print
            throw StorageError.fileReadError
        }
    }
}
