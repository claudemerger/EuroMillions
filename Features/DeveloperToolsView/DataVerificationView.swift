//
//  DataVerificationView.swift
//
//  Created on 28/02/2025.
//

import SwiftUI


// MARK: -

/// View for verifying data has been properly loaded
struct DataVerificationView: View {
    
    @EnvironmentObject var dataBaseBuilder: DataBaseBuilder
    //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
    @EnvironmentObject var appDataService: AppDataService
    
    
    @State private var debugMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Data Verification")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if appDataService.dataStore.isLoading {
                ProgressView("Loading data...")
            } else if appDataService.dataStore.hasError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(appDataService.dataStore.errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Data statistics
                Group {
                    DataStatRow(title: "Total Draws", value: "\(appDataService.dataStore.draws.count)")
                    DataStatRow(title: "Total Stars", value: "\(appDataService.dataStore.stars.count)")
                    DataStatRow(title: "Total Wins", value: "\(appDataService.dataStore.wins.count)")
                    
                    Divider()
                    
                    // Show latest draw if available
                    if !appDataService.dataStore.draws.isEmpty {
                        Text("Latest Draw:")
                            .font(.headline)
                        
                        let formattedDate = formatDate(appDataService.dataStore.drawDates.first)
                        Text("Date: \(formattedDate)")
                        
                        let numbers = appDataService.dataStore.draws.first?.map { String($0) }.joined(separator: ", ") ?? "None"
                        Text("Numbers: \(numbers)")
                        
                        let stars = appDataService.dataStore.stars.first?.map { String($0) }.joined(separator: ", ") ?? "None"
                        Text("Stars: \(stars)")
                    } else {
                        Text("No draw data available")
                            .foregroundColor(.secondary)
                    } // end if
                }
                .padding(.horizontal)
            } // end if
            
            // Debug message area
            if !debugMessage.isEmpty {
                ScrollView {
                    Text(debugMessage)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            } // end if
            
            Spacer()
            
            
            HStack {
                // Test Direct CSV Load Button
                Button(action: {
                    Task {
                        await testDirectCSVLoad()
                    }
                }) {
                    Text("Test Direct CSV")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } // end of Button Test Direct CSV
                
                // Normal Reload Button
                Button(action: {
                    Task {
                        try? await reloadData()
                    }
                }) {
                    Text("Reload Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } // end of button Reload Data
            } // end of HStack
            .padding(.horizontal)
            .disabled(appDataService.dataStore.isLoading)
        } // end of VStack
        .frame(width: 500, height: 600)
        .padding()
        
    } // end of body
    
    
    //MARK: - Helper
    /// Helper function to reload data
    func reloadData() async throws {
        debugMessage = "Starting reload data flow...\n"
        appDataService.dataStore.isLoading = true
        appDataService.dataStore.hasError = false
        
        do {
            debugMessage += "Building database...\n"
            let dataBase = try await dataBaseBuilder.buildDataBase()
            debugMessage += "Database built, size: \(dataBase.count) characters\n"
            
            debugMessage += "Building data store...\n"
            try await appDataService.dataStore.buildDataStore(dataBase: dataBase)
            debugMessage += "Data store built\n"
            
            appDataService.dataStore.isLoading = false
            debugMessage += "✅ Complete! Draws: \(appDataService.dataStore.draws.count), Stars: \(appDataService.dataStore.stars.count)\n"
        } catch {
            appDataService.dataStore.isLoading = false
            appDataService.dataStore.hasError = true
            appDataService.dataStore.errorMessage = error.localizedDescription
            debugMessage += "❌ Error: \(error.localizedDescription)\n"
        }
    }
    
    /// Test function to directly load and parse a sample CSV
    func testDirectCSVLoad() async {
        debugMessage = "Starting direct CSV test...\n"
        appDataService.dataStore.isLoading = true
        
        // Sample CSV data with a few rows
        let sampleCSV = """
        Day,Date,Ball1,Ball2,Ball3,Ball4,Ball5,Star1,Star2,Prize1,Prize2,Prize3,Prize4,Prize5
        Fri,17/03/2025,12,23,34,45,50,3,9,15000000,123456,78901,5432,123
        Tue,14/03/2025,5,17,26,31,42,5,11,12000000,98765,45678,3210,987
        """
        
        do {
            debugMessage += "Parsing sample CSV...\n"
            try await appDataService.dataStore.buildDataStore(dataBase: sampleCSV)
            
            appDataService.dataStore.isLoading = false
            debugMessage += "✅ Direct test complete! Draws: \(appDataService.dataStore.draws.count), Stars: \(appDataService.dataStore.stars.count)\n"
            
            if !appDataService.dataStore.draws.isEmpty {
                debugMessage += "Sample data:\n"
                debugMessage += "  - Date: \(formatDate(appDataService.dataStore.drawDates.first))\n"
                debugMessage += "  - Numbers: \(appDataService.dataStore.draws.first?.map { String($0) }.joined(separator: ", ") ?? "None")\n"
                debugMessage += "  - Stars: \(appDataService.dataStore.stars.first?.map { String($0) }.joined(separator: ", ") ?? "None")\n"
            }
        } catch {
            appDataService.dataStore.isLoading = false
            appDataService.dataStore.hasError = true
            appDataService.dataStore.errorMessage = error.localizedDescription
            debugMessage += "❌ Error: \(error.localizedDescription)\n"
        }
    }
    
    /// Helper function to format a date
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Helper
/// Helper view for displaying data statistics
struct DataStatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
