
///
//  DataParser.swift
//
//  Created by Claude on 14/02/2025.
//


import Foundation

/// `DataParser` is responsible for parsing EuroMillions CSV data base
///
/// This actor handles the complex process of:
/// - Parsing current and historical lottery draw data
/// - Extracting draw numbers, star numbers, and winning information
/// - Handling various data format variations
///
/// - Note: Uses actor to ensure thread-safe parsing operations
/// - Important: Supports parsing both current and historical data formats
actor DataParser {
    
    // MARK: - Error Types
    
    /// Defines specific error types that can occur during data parsing
    enum ParserError: Error {
        /// Indicates an invalid or unexpected data format
        case invalidFormat
        /// Signals missing required columns in the data
        case missingColumns
        /// Indicates an issue with date parsing
        case invalidDateFormat
        /// Signals problems converting number strings to integers
        case invalidNumberFormat
        /// Indicates issues parsing winning information
        case invalidWinningFormat
    }
    
    // MARK: - Properties
    
    /// Shared application settings
    private let settings = DataStoreSettings.sharedDataStoreSettings
    
    /// Column mapping configuration for parsing
    private let dataBaseColumnMapping: DataStoreSettings.dataBaseColumnMapping
    
    /// File format configuration
    private let fileFormatConfiguration: DataStoreSettings.FileFormatConfiguration

    // MARK: - Initialization
    /// Initializes the DataParser with default EuroMillions column mapping
    init() {
        self.dataBaseColumnMapping = settings.fileFormatConfiguration.dataBaseColumnMapping
        self.fileFormatConfiguration = settings.fileFormatConfiguration
    }
    
    
    // MARK: - Public Parsing Methods
    
    /// Parses current lottery draw data from a CSV string
    /// Extracts draw numbers, star numbers, and winning information
    /// - Parameter csvContent: Raw CSV string containing current draw data
    /// - Returns: A tuple with parsed draw records, star records, and win records
    /// - Throws: `ParserError` for various parsing issues
    
    func parseDataBase(_ csvContent: String) async throws -> (draws: [DrawRecord], stars: [StarRecord], wins: [WinRecord]) {
        // Split CSV content into rows, filtering out empty lines
        let rows = csvContent.components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }
        
        // Determine start index based on header configuration
        let startIndex = fileFormatConfiguration.hasHeader ? 1 : 0
        guard rows.count > startIndex else {
            print("❌ DataParser: No data rows found")
            throw ParserError.invalidFormat
        }
           
        var draws: [DrawRecord] = []
        var stars: [StarRecord] = []
        var wins: [WinRecord] = []
        
        // Track statistics for debug purposes
        var processedRows = 0
        var skippedRows = 0
        var historicalRows = 0
        var currentRows = 0
        
        // Process each row of data
        for rowIndex in startIndex..<rows.count {
            let columns = rows[rowIndex].components(separatedBy: fileFormatConfiguration.separator)
            
            // Determine if this is a historical (9 columns) or current (22 columns) row
            let isHistoricalRow = columns.count >= 9 && columns.count < dataBaseColumnMapping.rapport_du_rang13Column
            let isCurrentRow = columns.count >= dataBaseColumnMapping.rapport_du_rang13Column
            
            do {
                // Make sure we have at least enough columns for the draw and star numbers
                if isHistoricalRow || isCurrentRow {
                    // Parse date - this should be in the same position for both formats
                    guard columns.count > dataBaseColumnMapping.dateColumn else {
                        print("Warning: Row \(rowIndex) missing date column")
                        skippedRows += 1
                        continue
                    }
                    
                    let drawDate = try parseDate(columns[Int(dataBaseColumnMapping.dateColumn)])
                    
                    // Make sure we have enough columns for the numbers
                    if columns.count > dataBaseColumnMapping.ball5Column {
                        // Extract draw numbers
                        let numbers = try parseNumbers(columns: columns, mapping: "current")
                        draws.append(DrawRecord(date: drawDate, numbers: numbers))
                        
                        // Extract star numbers if we have enough columns
                        if columns.count > dataBaseColumnMapping.star2Column {
                            let starNumbers = try parseStars(columns: columns, mapping: "current")
                            stars.append(StarRecord(date: drawDate, stars: starNumbers))
                        }
                        
                        // Extract winning amounts only if this is a current row with enough columns
                        if isCurrentRow {
                            let winningAmounts = try parseWinnings(columns: columns)
                            wins.append(WinRecord(date: drawDate, wins: winningAmounts))
                            currentRows += 1
                        } else {
                            // For historical rows, add an empty wins record to maintain alignment
                            wins.append(WinRecord(date: drawDate, wins: []))
                            historicalRows += 1
                        }
                        
                        processedRows += 1
                    } else {
                        print("Warning: Row \(rowIndex) has insufficient columns for ball numbers: \(columns.count)")
                        skippedRows += 1
                    }
                } else {
                    print("Warning: Row \(rowIndex) has invalid column count: \(columns.count)")
                    skippedRows += 1
                }
            } catch {
                print("Warning: Skipping row \(rowIndex) due to parsing error: \(error)")
                skippedRows += 1
                continue
            }
        }
        
        /*
        // Print statistics for debugging
        print("📊 DataParser Statistics:")
        print("  - Total rows processed: \(processedRows)")
        print("  - Historical rows (9 columns): \(historicalRows)")
        print("  - Current rows (22 columns): \(currentRows)")
        print("  - Skipped rows: \(skippedRows)")
        
        // Verify data consistency
        _ = draws.count
        print("  - Draw records: \(draws.count)")
        print("  - Star records: \(stars.count)")
        print("  - Win records: \(wins.count)")
        
        if draws.count != stars.count || draws.count != wins.count {
            print("⚠️ Warning: Data inconsistency detected. Records counts don't match.")
        }
        */
        
        return (draws, stars, wins)
    }
    
    
    
    
    
    
    
    
    /*
    func parseDataBase(_ csvContent: String) async throws -> (draws: [DrawRecord], stars: [StarRecord], wins: [WinRecord]) {
        // Split CSV content into rows, filtering out empty lines
        let rows = csvContent.components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }
        
        // Determine start index based on header configuration
        let startIndex = fileFormatConfiguration.hasHeader ? 1 : 0
        guard rows.count > startIndex else {
            print("❌ DataParser: No data rows found")
            throw ParserError.invalidFormat
        }
           
        var draws: [DrawRecord] = []
        var stars: [StarRecord] = []
        var wins: [WinRecord] = []
        
        // Process each row of data
        for rowIndex in startIndex..<rows.count {
            let columns = rows[rowIndex].components(separatedBy: fileFormatConfiguration.separator)

            guard columns.count >= dataBaseColumnMapping.rapport_du_rang13Column else {
                print("Warning: Row \(rowIndex) has insufficient columns: \(columns.count)")
                continue
            }
             
            do {
                // Parse individual components of the draw
                let drawDate = try parseDate(columns[Int(dataBaseColumnMapping.dateColumn)])
                
                // Extract draw numbers
                let numbers = try parseNumbers(columns: columns, mapping: "current")
                draws.append(DrawRecord(date: drawDate, numbers: numbers))
                
                // Extract star numbers
                let starNumbers = try parseStars(columns: columns, mapping: "current")
                stars.append(StarRecord(date: drawDate, stars: starNumbers))
                
                // Extract winning amounts
                let winningAmounts = try parseWinnings(columns: columns)
                wins.append(WinRecord(date: drawDate, wins: winningAmounts))
                
            } catch {
                print("Warning: Skipping row \(rowIndex) due to parsing error: \(error)")
                continue
            }
        }
        
        return (draws, stars, wins)
    }
    */
    
    // MARK: - Private Parsing Helper Methods
    
    /// Parses a date string into a `Date` object
    ///
    /// - Parameter dateString: String representation of the date
    /// - Returns: Parsed `Date` object
    /// - Throws: `ParserError.invalidDateFormat` if parsing fails
    ///
    private func parseDate(_ dateString: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        
        guard let date = formatter.date(from: dateString.trimmingCharacters(in: .whitespaces)) else {
            throw ParserError.invalidDateFormat
        }
        return date
    }
    
    
    /// Extracts draw numbers from CSV columns
    ///
    /// - Parameters:
    ///   - columns: Array of column values
    ///   - mapping: Specifies which column mapping to use ("current" or "historical")
    /// - Returns: Array of draw numbers
    /// - Throws: `ParserError.invalidNumberFormat` if number parsing fails
    
    private func parseNumbers(columns: [String], mapping: String) throws -> [Int] {
        // Select appropriate column indices based on mapping type
        let numberColumns = [
            dataBaseColumnMapping.ball1Column,
            dataBaseColumnMapping.ball2Column,
            dataBaseColumnMapping.ball3Column,
            dataBaseColumnMapping.ball4Column,
            dataBaseColumnMapping.ball5Column
        ]

        // Convert column values to integers
        let numbers = try numberColumns.map { columnIndex in
            guard let number = Int(columns[columnIndex].trimmingCharacters(in: .whitespaces)) else {
                throw ParserError.invalidNumberFormat
            }
            return number
        }
        
        return numbers
    }
    
    
    /// Extracts star numbers from CSV columns
    ///
    /// - Parameters:
    ///   - columns: Array of column values
    ///   - mapping: Specifies which column mapping to use ("current" or "historical")
    /// - Returns: Array of star numbers
    /// - Throws: `ParserError.invalidNumberFormat` if number parsing fails
    ///
    private func parseStars(columns: [String], mapping: String) throws -> [Int] {
        // Select appropriate column indices based on mapping type
        let starColumns = [
            dataBaseColumnMapping.star1Column,
            dataBaseColumnMapping.star2Column
        ]
        
        // Convert column values to integers
        let stars = try starColumns.map { columnIndex in
            guard let star = Int(columns[columnIndex].trimmingCharacters(in: .whitespaces)) else {
                throw ParserError.invalidNumberFormat
            }
            return star
        }
        
        return stars
    }

    
    /// Parses winning amounts from CSV columns
    ///
    /// Extracts prize amounts for different winning ranks
    ///
    /// - Parameter columns: Array of column values
    /// - Returns: Array of winning amounts
    ///
    /// - Throws: `ParserError.invalidWinningFormat` if amount parsing fails
    private func parseWinnings(columns: [String]) throws -> [Double] {
        // Define columns for different prize ranks
        let rankColumns = [
            dataBaseColumnMapping.rapport_du_rang1Column,
            dataBaseColumnMapping.rapport_du_rang2Column,
            dataBaseColumnMapping.rapport_du_rang3Column,
            dataBaseColumnMapping.rapport_du_rang4Column,
            dataBaseColumnMapping.rapport_du_rang5Column,
            dataBaseColumnMapping.rapport_du_rang6Column,
            dataBaseColumnMapping.rapport_du_rang7Column,
            dataBaseColumnMapping.rapport_du_rang8Column,
            dataBaseColumnMapping.rapport_du_rang9Column,
            dataBaseColumnMapping.rapport_du_rang10Column,
            dataBaseColumnMapping.rapport_du_rang11Column,
            dataBaseColumnMapping.rapport_du_rang12Column,
            dataBaseColumnMapping.rapport_du_rang13Column
        ]
        
        var winningAmounts: [Double] = []
        
        // Process each rank's prize amount
        for columnIndex in rankColumns {
            let prizeString = columns[columnIndex].trimmingCharacters(in: .whitespaces)
            
            if !prizeString.isEmpty {
                // Clean and convert prize string to a numeric value
                let amountString = prizeString
                    .replacingOccurrences(of: "€", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                
                if let amount = Double(amountString) {
                    winningAmounts.append(amount)
                }
            }
        }
        
        return winningAmounts
    }
}









/*


import Foundation

/// `DataParser` is responsible for parsing EuroMillions CSV data base
///
/// This actor handles the complex process of:
/// - Parsing current and historical lottery draw data
/// - Extracting draw numbers, star numbers, and winning information
/// - Handling various data format variations
///
/// - Note: Uses actor to ensure thread-safe parsing operations
/// - Important: Supports parsing both current and historical data formats
actor DataParser {
    
    // MARK: - Error Types
    
    /// Defines specific error types that can occur during data parsing
    enum ParserError: Error {
        /// Indicates an invalid or unexpected data format
        case invalidFormat
        /// Signals missing required columns in the data
        case missingColumns
        /// Indicates an issue with date parsing
        case invalidDateFormat
        /// Signals problems converting number strings to integers
        case invalidNumberFormat
        /// Indicates issues parsing winning information
        case invalidWinningFormat
    }
    
    // MARK: - Properties
        
        /// Shared application settings
        private let settings = DataStoreSettings.sharedDataStoreSettings
        
        /// Column mapping configuration for parsing
        private let dataBaseColumnMapping: DataStoreSettings.dataBaseColumnMapping
        
        /// File format configuration
        private let fileFormatConfiguration: DataStoreSettings.FileFormatConfiguration

        // MARK: - Initialization
        /// Initializes the DataParser with default EuroMillions column mapping
        init() {
            self.dataBaseColumnMapping = settings.fileFormatConfiguration.dataBaseColumnMapping
            self.fileFormatConfiguration = settings.fileFormatConfiguration
        }
    
    // MARK: - Public Parsing Methods
    
    /// Parses current lottery draw data from a CSV string
    ///
    /// Extracts draw numbers, star numbers, and winning information
    ///
    /// - Parameter csvContent: Raw CSV string containing current draw data
    /// - Returns: A tuple with parsed draw records, star records, and win records
    /// - Throws: `ParserError` for various parsing issues
    func parseDataBase(_ csvContent: String) async throws -> (draws: [DrawRecord], stars: [StarRecord], wins: [WinRecord]) {
        // Split CSV content into rows, filtering out empty lines
        let rows = csvContent.components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }
        
        // Determine start index based on header configuration
        let startIndex = DataStoreSettings.FileFormatConfiguration.hasHeader ? 1 : 0
        guard rows.count > startIndex else {
            print("❌ DataParser: No data rows found")
            throw ParserError.invalidFormat
        }
           
        var draws: [DrawRecord] = []
        var stars: [StarRecord] = []
        var wins: [WinRecord] = []
        
        // Process each row of data
        for rowIndex in startIndex..<rows.count {
            let columns = rows[rowIndex].components(separatedBy: settings.dataBaseColumnMapping.separator)

            guard columns.count >= columnMapping.rapport_du_rang13Column else {
                print("Warning: Row \(rowIndex) has insufficient columns: \(columns.count)")
                continue
            }
             
            do {
                // Parse individual components of the draw
                let drawDate = try parseDate(columns[dataBaseColumnMapping.dateColumn])
                
                // Extract draw numbers
                let numbers = try parseNumbers(columns: columns, mapping: "current")
                draws.append(DrawRecord(date: drawDate, numbers: numbers))
                
                // Extract star numbers
                let starNumbers = try parseStars(columns: columns, mapping: "current")
                stars.append(StarRecord(date: drawDate, stars: starNumbers))
                
                // Extract winning amounts
                let winningAmounts = try parseWinnings(columns: columns)
                wins.append(WinRecord(date: drawDate, wins: winningAmounts))
                
            } catch {
                print("Warning: Skipping row \(rowIndex) due to parsing error: \(error)")
                continue
            }
        }
        
        return (draws, stars, wins)
    }
    
    
    // MARK: - Private Parsing Helper Methods
    
    /// Parses a date string into a `Date` object
    ///
    /// - Parameter dateString: String representation of the date
    /// - Returns: Parsed `Date` object
    /// - Throws: `ParserError.invalidDateFormat` if parsing fails
    ///
    private func parseDate(_ dateString: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        
        guard let date = formatter.date(from: dateString.trimmingCharacters(in: .whitespaces)) else {
            throw ParserError.invalidDateFormat
        }
        return date
    }
    
    
    /// Extracts draw numbers from CSV columns
    ///
    /// - Parameters:
    ///   - columns: Array of column values
    ///   - mapping: Specifies which column mapping to use ("current" or "historical")
    /// - Returns: Array of draw numbers
    /// - Throws: `ParserError.invalidNumberFormat` if number parsing fails
    ///
    private func parseNumbers(columns: [String], mapping: String) throws -> [Int] {
        // Select appropriate column indices based on mapping type
        var numberColumns: [Int] = []
        
        numberColumns = [
            dataBaseColumnMapping.ball1Column,
            dataBaseColumnMapping.ball2Column,
            dataBaseColumnMapping.ball3Column,
            dataBaseColumnMapping.ball4Column,
            dataBaseColumnMapping.ball5Column
        ]

        // Convert column values to integers
        let numbers = try numberColumns.map { columnIndex in
            guard let number = Int(columns[columnIndex].trimmingCharacters(in: .whitespaces)) else {
                throw ParserError.invalidNumberFormat
            }
            return number
        }
        
        return numbers
    }
    
    
    /// Extracts star numbers from CSV columns
    ///
    /// - Parameters:
    ///   - columns: Array of column values
    ///   - mapping: Specifies which column mapping to use ("current" or "historical")
    /// - Returns: Array of star numbers
    /// - Throws: `ParserError.invalidNumberFormat` if number parsing fails
    ///
    private func parseStars(columns: [String], mapping: String) throws -> [Int] {
        // Select appropriate column indices based on mapping type
        var starColumns: [Int] = []
        
            starColumns = [
                dataBaseColumnMapping.star1Column,
                dataBaseColumnMapping.star2Column
            ]
        
        // Convert column values to integers
        let stars = try starColumns.map { columnIndex in
            guard let star = Int(columns[columnIndex].trimmingCharacters(in: .whitespaces)) else {
                throw ParserError.invalidNumberFormat
            }
            return star
        }
        
        return stars
    }

    
    /// Parses winning amounts from CSV columns
    ///
    /// Extracts prize amounts for different winning ranks
    ///
    /// - Parameter columns: Array of column values
    /// - Returns: Array of winning amounts
    ///
    /// - Throws: `ParserError.invalidWinningFormat` if amount parsing fails
    private func parseWinnings(columns: [String]) throws -> [Double] {
        // Define columns for different prize ranks
        let rankColumns = [
            dataBaseColumnMapping.rapport_du_rang1Column,
            dataBaseColumnMapping.rapport_du_rang2Column,
            dataBaseColumnMapping.rapport_du_rang3Column,
            dataBaseColumnMapping.rapport_du_rang4Column,
            dataBaseColumnMapping.rapport_du_rang5Column,
            dataBaseColumnMapping.rapport_du_rang6Column,
            dataBaseColumnMapping.rapport_du_rang7Column,
            dataBaseColumnMapping.rapport_du_rang8Column,
            dataBaseColumnMapping.rapport_du_rang9Column,
            dataBaseColumnMapping.rapport_du_rang10Column,
            dataBaseColumnMapping.rapport_du_rang11Column,
            dataBaseColumnMapping.rapport_du_rang12Column,
            dataBaseColumnMapping.rapport_du_rang13Column
        ]
        
        var winningAmounts: [Double] = []
        
        // Process each rank's prize amount
        for columnIndex in rankColumns {
            let prizeString = columns[columnIndex].trimmingCharacters(in: .whitespaces)
            
            if !prizeString.isEmpty {
                // Clean and convert prize string to a numeric value
                let amountString = prizeString
                    .replacingOccurrences(of: "€", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                
                if let amount = Double(amountString) {
                    winningAmounts.append(amount)
                }
            }
        }
        
        return winningAmounts
    }
}
*/
