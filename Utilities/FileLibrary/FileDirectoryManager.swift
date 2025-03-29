//
//  FileDirectoryManager.swift
//  EuroMillionsDownloader
//
//  Created by Claude sur iCloud on 19/01/2025.
//

import Foundation
import SwiftUI
import AppKit

/// A manager class that handles file saving operations for FDJ game data.
/// This class manages the directory structure and file saving operations for both EuroMillions and Loto data.
/// It uses the system save panel to allow users to choose save locations while suggesting an organized directory structure.
///
/// Usage example:
/// ```swift
/// if let savedURL = FDJDirectoryManager.shared.saveFile(
///     data: csvString,
///     filename: "euromillions_consolidated.csv",
///     gameType: .euromillions
/// ) {
///     print("File saved at: \(savedURL.path)")
/// }
/// ```
///
/*
class FDJDirectoryManager {
    /// Shared instance for the directory manager.
    /// Use this singleton instance to perform all file operations.
    static let shared = FDJDirectoryManager()
    
    /// The root directory name for all FDJ-related files.
    /// This directory will be suggested as a subdirectory of the user's Downloads folder.
    private let rootDirectoryName = "FDJ"
    
    /// Private initializer to enforce singleton pattern.
    private init() {}
    
    /// Saves data to a file using a system save panel.
    ///
    /// This method performs the following operations:
    /// 1. Opens a system save panel dialog
    /// 2. Suggests a default save location in Downloads/FDJ/[GameType]
    /// 3. Allows the user to choose a different location if desired
    /// 4. Saves the file with proper permissions
    ///
    /// - Parameters:
    ///   - data: The string content to be saved to the file
    ///   - filename: The suggested name for the file (e.g., "euromillions_consolidated.csv")
    ///   - gameType: The type of game data being saved (.euromillions or .loto)
    ///
    /// - Returns: The URL where the file was saved, or nil if the save operation was cancelled or failed
    ///
    /// - Note: This method handles directory creation and file permissions automatically
    func saveFile(data: String, filename: String, gameType: GameType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Save FDJ Data"
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.canCreateDirectories = true
        
        // Suggest the Downloads/FDJ directory structure
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let suggestedURL = downloadsURL
                .appendingPathComponent(rootDirectoryName)
                .appendingPathComponent(gameType.directoryName)
            
            // Try to create the directory structure only when we have a valid Downloads URL
            do {
                try FileManager.default.createDirectory(
                    at: suggestedURL,
                    withIntermediateDirectories: true
                )
                savePanel.directoryURL = suggestedURL
            } catch {
                // If we can't create the directory, just default to Downloads
                savePanel.directoryURL = downloadsURL
            }
        }
        
        let response = savePanel.runModal()
        
        guard response == .OK,
              let saveURL = savePanel.url else {
            return nil
        }
        
        do {
            try data.write(to: saveURL, atomically: true, encoding: .utf8)
            print("✅ File saved successfully at: \(saveURL.path)")
            return saveURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
}

/// Represents the different types of FDJ games supported by the directory manager.
///
/// Each game type corresponds to a specific subdirectory in the FDJ folder structure.
enum GameType {
    /// EuroMillions game type
    case euromillions
    /// Loto game type
    case loto
    
    /// The directory name associated with each game type
    var directoryName: String {
        switch self {
        case .euromillions:
            return "EuroMillions"
        case .loto:
            return "Loto"
        }
    }
}
*/

/*
class FDJDirectoryManager {
    static let shared = FDJDirectoryManager()
    
    private let rootDirectoryName = "FDJ"
    private init() {}
    
    func saveFile(data: String, filename: String, gameType: GameType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Save FDJ Data"
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.canCreateDirectories = true
        
        // Suggest the Downloads/FDJ directory structure
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let suggestedURL = downloadsURL
                .appendingPathComponent(rootDirectoryName)
                .appendingPathComponent(gameType.directoryName)
            
            // Try to create the directory structure only when we have a valid Downloads URL
            do {
                try FileManager.default.createDirectory(
                    at: suggestedURL,
                    withIntermediateDirectories: true
                )
                savePanel.directoryURL = suggestedURL
            } catch {
                // If we can't create the directory, just default to Downloads
                savePanel.directoryURL = downloadsURL
            }
        }
        
        let response = savePanel.runModal()
        
        guard response == .OK,
              let saveURL = savePanel.url else {
            return nil
        }
        
        do {
            try data.write(to: saveURL, atomically: true, encoding: .utf8)
            print("✅ File saved successfully at: \(saveURL.path)")
            return saveURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
}

enum GameType {
    case euromillions
    case loto
    
    var directoryName: String {
        switch self {
        case .euromillions:
            return "EuroMillions"
        case .loto:
            return "Loto"
        }
    }
}
*/


/*
import Foundation
import SwiftUI
import AppKit

class FDJDirectoryManager {
    static let shared = FDJDirectoryManager()
    
    private let rootDirectoryName = "FDJ"
    
    private init() {
        setupDirectoryStructure()
    }
    
    private func setupDirectoryStructure() {
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fdjURL = downloadsURL.appendingPathComponent(rootDirectoryName)
        let directories = [
            fdjURL,
            fdjURL.appendingPathComponent("EuroMillions"),
            fdjURL.appendingPathComponent("Loto")
        ]
        
        for directory in directories {
            do {
                if !FileManager.default.fileExists(atPath: directory.path) {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                }
            } catch {
                print("⚠️ Could not create directory at \(directory.path): \(error)")
            }
        }
    }
    
    func saveFile(data: String, filename: String, gameType: GameType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Save FDJ Data"
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.canCreateDirectories = true
        
        // Set initial directory to the game-specific folder
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let gameDirectory = downloadsURL
                .appendingPathComponent(rootDirectoryName)
                .appendingPathComponent(gameType.directoryName)
            savePanel.directoryURL = gameDirectory
        }
        
        let response = savePanel.runModal()
        
        guard response == .OK,
              let saveURL = savePanel.url else {
            return nil
        }
        
        do {
            try data.write(to: saveURL, atomically: true, encoding: .utf8)
            print("✅ File saved successfully at: \(saveURL.path)")
            return saveURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
}

enum GameType {
    case euromillions
    case loto
    
    var directoryName: String {
        switch self {
        case .euromillions:
            return "EuroMillions"
        case .loto:
            return "Loto"
        }
    }
}
*/

/*
import Foundation
import SwiftUI
import AppKit

class FDJDirectoryManager {
    static let shared = FDJDirectoryManager()
    
    private init() {}
    
    func saveFile(data: String, filename: String, gameType: GameType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Save FDJ Data"
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.canCreateDirectories = true
        
        // Suggest the Downloads/FDJ directory as the default location
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let suggestedURL = downloadsURL.appendingPathComponent("FDJ").appendingPathComponent(gameType.directoryName)
            savePanel.directoryURL = suggestedURL
        }
        
        let response = savePanel.runModal()
        
        guard response == .OK,
              let saveURL = savePanel.url else {
            return nil
        }
        
        do {
            // Create parent directories if they don't exist
            let parentDirectory = saveURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: parentDirectory,
                withIntermediateDirectories: true
            )
            
            // Save the file
            try data.write(to: saveURL, atomically: true, encoding: .utf8)
            print("✅ File saved successfully at: \(saveURL.path)")
            return saveURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
}

enum GameType {
    case euromillions
    case loto
    
    var directoryName: String {
        switch self {
        case .euromillions:
            return "EuroMillions"
        case .loto:
            return "Loto"
        }
    }
}
*/


/*
import Foundation

class FDJDirectoryManager {
    static let shared = FDJDirectoryManager()
    
    private let rootDirectoryName = "FDJ"
    private let euromillionsDirectoryName = "EuroMillions"
    private let lotoDirectoryName = "Loto"
    
    private init() {
        setupDirectories()
    }
    
    /// Base URL for the FDJ directory in Downloads
    var fdjDirectoryURL: URL? {
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        return downloadsURL?.appendingPathComponent(rootDirectoryName)
    }
    
    var euromillionsDirectoryURL: URL? {
        fdjDirectoryURL?.appendingPathComponent(euromillionsDirectoryName)
    }
    
    var lotoDirectoryURL: URL? {
        fdjDirectoryURL?.appendingPathComponent(lotoDirectoryName)
    }
    
    private func setupDirectories() {
        guard let fdjDirectory = fdjDirectoryURL else { return }
        
        let directories = [
            fdjDirectory,
            fdjDirectory.appendingPathComponent(euromillionsDirectoryName),
            fdjDirectory.appendingPathComponent(lotoDirectoryName)
        ]
        
        for directory in directories {
            do {
                if !FileManager.default.fileExists(atPath: directory.path) {
                    try FileManager.default.createDirectory(
                        at: directory,
                        withIntermediateDirectories: true
                    )
                    // Make the directory visible in Finder
                    try FileManager.default.setAttributes(
                        [.posixPermissions: 0o755],
                        ofItemAtPath: directory.path
                    )
                }
            } catch {
                print("❌ Error creating directory at \(directory.path): \(error)")
            }
        }
    }
    
    func saveFile(data: String, filename: String, gameType: GameType) -> URL? {
        let directory: URL?
        
        switch gameType {
        case .euromillions:
            directory = euromillionsDirectoryURL
        case .loto:
            directory = lotoDirectoryURL
        }
        
        guard let saveURL = directory?.appendingPathComponent(filename) else {
            return nil
        }
        
        do {
            try data.write(to: saveURL, atomically: true, encoding: .utf8)
            // Make the file readable
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o644],
                ofItemAtPath: saveURL.path
            )
            print("✅ File saved successfully at: \(saveURL.path)")
            return saveURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
}

enum GameType {
    case euromillions
    case loto
}
*/
