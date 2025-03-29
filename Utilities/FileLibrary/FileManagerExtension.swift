//
//  FileManagerExtension.swift
//  EuroMillionsDownloader
//
//  Created by Claude sur iCloud on 06/01/2025.
//


import Foundation

// MARK: - File Manager Extension
extension FileManager {
    
    
    /*
    static func getDocumentsDirectory() throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.cannotFindHost)
        }
        return documentsDirectory
    }
    */
    
    ///  This function generates the path of the specified file
    ///  Parameters:
    ///  - fileName
    ///  Returns:
    ///  - the complete file path
    static func getFilePath(for filename: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access documents directory")
            return nil
        }
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    
    /// This function creates a temporary directory
    static func createTempDirectory() -> URL? {
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDirectory,
                                                 withIntermediateDirectories: true)
            return tempDirectory
        } catch {
            print("❌ Could not create temp directory: \(error)")
            return nil
        }
    }
    
    
    // Add file management helpers
    static func fileExists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    
    static func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
} // end of extension

