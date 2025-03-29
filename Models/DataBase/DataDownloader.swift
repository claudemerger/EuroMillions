//
//  DataDownloader.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 16/03/2025.
//


import Foundation
import ZIPFoundation


/// `EuroMilliosDataDownloader` is responsible for downloading, unzipping, and managing game data files.
///
/// This actor handles the entire process of:
/// - Downloading compressed data files from a specified source
/// - Extracting CSV files from ZIP archives
/// - Managing temporary file storage
/// - Cleaning up temporary files
///
/// - Note: Uses `actor` to provide safe concurrent access to download operations
/// - Important: Relies on `AppConfiguration` for download configuration
actor DataDownloader {
    
    /// File manager for file system operations
    private let fileManager = FileManager.default
    
    /// Shared application configuration
    private let config = DataBaseSettings.sharedDataBaseSettings
    
    /// Downloads game data file from the specified source
    ///
    /// This method performs a complete download workflow:
    /// 1. Validates game configuration
    /// 2. Creates a temporary directory
    /// 3. Downloads ZIP file
    /// 4. Extracts CSV from ZIP
    /// 5. Reads CSV content
    /// 6. Cleans up temporary files
    ///
    /// - Parameter gameName: Name of the game to download data for (e.g., "euromillions", "loto")
    /// - Returns: The contents of the downloaded CSV file as a string
    /// - Throws: `FileError` or other download-related errors
    
    func downloadGameData(for gameName: String) async throws -> String {

        // Create a unique temporary directory for this download
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Prepare file URLs
        let zipFileURL = tempDirectory.appendingPathComponent("\(gameName)_data.zip")
        let csvFileURL = tempDirectory.appendingPathComponent("\(gameName)_data.csv")
        
        do {
            // 1. Construct download URL from configuration
            let dataSource = config.fdjDataSource
            let downloadURL = URL(string: "\(dataSource.baseURL)\(dataSource.endpointPath)")!
            
            // 2. Download ZIP file
            let downloadedFile = try await downloadFile(from: downloadURL, to: zipFileURL)
            
            // 3. Unzip downloaded file
            try await unzipFile(at: downloadedFile, to: csvFileURL)
            
            // 4. Read CSV content
            let csvContent = try String(contentsOf: csvFileURL, encoding: .utf8)

            // 5. Clean up temporary directory
            try? FileManager.default.removeItem(at: tempDirectory)
            try? await FileUtilities.cleanupOldTempFiles()
            
            return csvContent
            
        } catch {
            // Ensure cleanup in case of any error
            try? FileManager.default.removeItem(at: tempDirectory)
            throw error
        }
    }
    
    /// Downloads a file from a web URL to a local destination
    ///
    /// - Parameters:
    ///   - webFileURL: Source URL of the file to download
    ///   - destinationURL: Local URL where the file will be saved
    /// - Returns: URL of the downloaded file
    /// - Throws: `URLError` for network-related issues
    private func downloadFile(from webFileURL: URL, to destinationURL: URL) async throws -> URL {
        // Download file using URLSession
        let (tempFileURL, response) = try await URLSession.shared.download(from: webFileURL)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: destinationURL)
        
        // Move downloaded file to destination
        try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
        
        return destinationURL
    }
    
    
    /// Extracts a CSV file from a ZIP archive
    ///
    /// - Parameters:
    ///   - zipFileURL: URL of the ZIP file to extract
    ///   - csvFileURL: Destination URL for the extracted CSV file
    /// - Throws: `FileError` for various extraction issues
    private func unzipFile(at zipFileURL: URL, to csvFileURL: URL) async throws {
        // Verify ZIP file exists
        guard FileManager.default.fileExists(atPath: zipFileURL.path) else {
            print("❌ Zip file not found at: \(zipFileURL.path)")
            throw FileError.fileNotFound
        }
        
        let tempDirectory = zipFileURL.deletingLastPathComponent()
        
        do {
            // Unzip the file
            try FileManager.default.unzipItem(at: zipFileURL, to: tempDirectory)
            
            // Find CSV files in the unzipped contents
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: tempDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            let csvFiles = directoryContents.filter { $0.pathExtension.lowercased() == "csv" }
            
            // Ensure at least one CSV file is found
            guard let extractedFileURL = csvFiles.first else {
                print("❌ No CSV file found in unzipped contents")
                throw FileError.fileNotFound
            }
            
            // Move CSV to final destination if needed
            if extractedFileURL.path != csvFileURL.path {
                try? FileManager.default.removeItem(at: csvFileURL)
                try FileManager.default.moveItem(at: extractedFileURL, to: csvFileURL)
            }
            
        } catch {
            print("❌ Error during unzip process: \(error)")
            throw FileError.unzipError
        }
    }
} // end of actor
