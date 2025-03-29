//
//  FileUtilities.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 17/03/2025.
//

import Foundation

/// Defines specific file-related errors that can occur during file operations
public enum FileError: Error {
    /// Indicates an invalid or missing URL configuration
    case invalidURL
    /// Indicates that a required file is not found
    case fileNotFound
    /// Indicates an error during file unzipping process
    case unzipError
    /// Indicates an error during file cleanup
    case cleanupError
    ///
    case downloadError
    case fileProcessingError
    case dataConversionError
    case invalidData
    case processingError
    case invalidEncoding
    case emptyFile
    
    /*
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL or file path"
        case .downloadError:
            return "Failed to download the file"
        case .fileProcessingError:
            return "Failed to process the file"
        case .dataConversionError:
            return "Failed to convert data"
        case .invalidData:
            return "Invalid data format"
        case .fileNotFound:
            return "File not found"
        case .unzipError:
            return "Error while unzipping the file"
        case .processingError:
            return "Error processing file"
        case .invalidEncoding:
            return "Could not read file with any supported encoding"
        case .emptyFile:
            return "File is empty or contains no valid data"
        }
     */
} // end of enum

/// A collection of file system utility functions
public struct FileUtilities {
    
    /// Function to clean the document directory from old files
    public static func cleanupFiles() {
        print("Cleanup Files ....")
        do {
            let documentsDirectory: URL = try FileManager.getDocumentsDirectory()
            
            // remove zip file
            let zipFileURL = documentsDirectory.appendingPathComponent("zipFile.zip")
            // Check if the file exists before attempting to remove it
            if FileManager.default.fileExists(atPath: zipFileURL.path) {
                try FileManager.default.removeItem(at: zipFileURL)
                print("ZIP file successfully removed")
            } else {
                print("ZIP file not found")
            }
        } catch {
            print("Error cleaning directory: \(error.localizedDescription)")
        } // end of do
        
        // remove csv file
        do {
            let documentsDirectory: URL = try FileManager.getDocumentsDirectory()
            
            // cleanup csv file
            let csvFileURL = documentsDirectory.appendingPathComponent("csvFile.csv")
            // Check if the file exists before attempting to remove it
            if FileManager.default.fileExists(atPath: csvFileURL.path) {
                try FileManager.default.removeItem(at: csvFileURL)
                print("CSV file successfully removed")
            } else {
                print("CSV file not found")
            }
        } catch {
            print("Error cleaning directory: \(error.localizedDescription)")
        } //end of do
    } // end of func cleanupFiles

    /// Removes temporary directories older than 24 hours
    ///
    /// This method helps manage disk space by:
    /// - Identifying temporary directories created by the app
    /// - Removing directories older than 24 hours
    ///
    /// - Note: Logs the number of cleaned up directories
    public static func cleanupOldTempFiles() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
        let contents = try FileManager.default.contentsOfDirectory(
            at: tempDirectory,
            includingPropertiesForKeys: [.creationDateKey, .isDirectoryKey]
        )
        
        // Track number of cleaned directories
        var cleanedCount = 0
        
        for url in contents {
            // Only process app-created temp directories (UUID-named)
            guard url.lastPathComponent.count == 36, // UUID length
                  let isDirectory = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                  isDirectory else {
                continue
            }
            
            // Remove directories older than 24 hours
            if let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate,
               Date().timeIntervalSince(creationDate) > 24 * 3600 {
                
                try FileManager.default.removeItem(at: url)
                cleanedCount += 1
            }
        }
        
        //print("🧹 Cleaned up \(cleanedCount) old temporary directories")
    }

    /// Removes a specific temporary directory
    ///
    /// - Parameter directory: URL of the directory to be removed
    /// - Throws: `FileError.cleanupError` if removal fails
    public static func cleanupTempFiles(in directory: URL) throws {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        
        do {
            try FileManager.default.removeItem(at: directory)
        } catch {
            print("❌ Error cleaning up temporary directory: \(error)")
            throw FileError.cleanupError
        }
    }
}

// Extension to add convenience methods to FileManager
public extension FileManager {
    /// Returns the documents directory URL
    /// - Throws: Error if the documents directory can't be found
    /// - Returns: URL to the documents directory
    static func getDocumentsDirectory() throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileError.fileNotFound
        }
        return documentsDirectory
    }
}
