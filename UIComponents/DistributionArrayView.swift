//
//  DistributionArrayView.swift
//  Loto
//
//  Created by Claude sur iCloud on 26/12/2024.
//

import SwiftUI
import SwiftData


/// This structure displays the distribution table passed as an argument "distribution"
/// A view that displays a 2D distribution table with configurable styling
///
struct DistributionArrayView: View {
    
    // MARK: - Properties
    let distribution: [[Int]]
    
    var cellWidth: CGFloat = 30
    var cellHeight: CGFloat = 15
    var cellBackgroundColor: Color = .gray.opacity(0.1)
    var textColor: Color = .primary
    var fontSize: CGFloat = 12
    
    // MARK: - Private Properties
    private var rows: Int { distribution.count }
    private var columns: Int { distribution.isEmpty ? 0 : distribution[0].count }
    
    // MARK: - Body
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { column in
                            Cell(value: distribution[row][column])
                        } // end of ForEach
                    } // end of HStack
                } // end of ForEach
            } // end of VStack
        } // end of ScrollView
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } // end of body
    
    // MARK: - Cell View
    private struct Cell: View {
        let value: Int
        
        @Environment(\.distributionArrayStyle) private var style
        
        var body: some View {
            Text(value.description)
                .frame(width: style.cellWidth, height: style.cellHeight)
                .background(style.cellBackgroundColor)
                .foregroundColor(style.textColor)
                .font(.system(size: style.fontSize))
                .multilineTextAlignment(.center)
                .border(Color.gray.opacity(0.2), width: 0.5)
        }
    }
} // end of struct

// MARK: - Style Configuration
struct DistributionArrayStyle {
    var cellWidth: CGFloat = 35
    var cellHeight: CGFloat = 15
    var cellBackgroundColor: Color = .gray.opacity(0.1)
    var textColor: Color = .primary
    var fontSize: CGFloat = 12
} // end of struct DistributionArrayStyle


// MARK: - Environment Key
private struct DistributionArrayStyleKey: EnvironmentKey {
    static let defaultValue = DistributionArrayStyle()
}  // end of struct DistributionArrayStyleKey

extension EnvironmentValues {
    var distributionArrayStyle: DistributionArrayStyle {
        get { self[DistributionArrayStyleKey.self] }
        set { self[DistributionArrayStyleKey.self] = newValue }
    } // end of var
} // end of extension EnvironmentValues


// MARK: - View Modifier
extension View {
    func distributionArrayStyle(_ style: DistributionArrayStyle) -> some View {
        environment(\.distributionArrayStyle, style)
    } // end of function distributionArrayStyle
} // end of extension View


/*
// MARK: - Preview
#Preview {
    // Create a simple wrapper view to handle the async loading
    struct PreviewWrapper: View {
        @State private var distributionArray: [[Int]] = [[0], [0]]  // Default values
        
        var body: some View {
            Group {
                if distributionArray == [[0], [0]] {
                    ProgressView()  // Show loading indicator
                } else {
                    DistributionArrayView(distribution: distributionArray)
                }
            }
            .onAppear {
                // Setup and load data
                Task {
                    
                    // 1. Create in-memory database configuration
                    let previewConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                    let previewContainer = try! ModelContainer(for: GameItem.self, configurations: previewConfig)
                    
                    // 2. Create a mock DataStore
                    let previewDataStore = DataStoreClass.createPreviewStore(context: previewContainer.mainContext)
                    
                    // Ensure data is loaded
                    await previewDataStore.loadData(context: previewContainer.mainContext)
                    
                    // 3. Create WeightAnalysis instance
                    let weightAnalysis = WeightAnalysis(dataStoreInstance: previewDataStore)
                    
                    // 4. Generate the table of occurrences
                    let tableDesOccurences = weightAnalysis.safeWeightTable(distance: 147)
                    
                    // Debug prints
                    //print("Table des occurrences: \(tableDesOccurences)")
                    
                    // 5. Generate the distribution array
                    let distribution = generateDistributionArrayFromArray(from: tableDesOccurences)
                    //print("Distribution generated: \(distribution)")
                    
                    // Update the view on the main thread
                    await MainActor.run {
                        self.distributionArray = distribution
                    }
                }
            }
            .frame(width: 600, height: 500)
        }
    }
    
    return PreviewWrapper()
}
*/
