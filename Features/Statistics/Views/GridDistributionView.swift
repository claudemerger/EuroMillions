
//  GridDistributionView.swift
//
//  Created by Claude sur iCloud on 22/11/2024.
//

import SwiftUI

///  This file implements the views for displaying grid distribution analysis results
///  in a tabular format, showing patterns across different grid configurations.
// MARK: - Main View
/// Displays the complete grid distribution analysis in a formatted table
struct GridDistributionView: View {
    let dataStoreBuilder: DataStoreBuilder
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.standard) {
            Text("Distribution des Configurations Grille")
                .font(.headline)
                .padding(.bottom, AppConfig.UI.Padding.small)
            
            Grid(alignment: .leading, horizontalSpacing: AppConfig.UI.Spacing.standard, verticalSpacing: AppConfig.UI.Spacing.small) {
                
                GridHeaderView()
                
                GridSubHeaderView()
                
                Divider()
                    .gridCellUnsizedAxes([.horizontal])
                    .padding(.vertical, AppConfig.UI.Padding.small)
                
                
                ForEach(GridConfiguration.Pattern.allCases, id: \.self) { pattern in
                    GridDataRow(pattern: pattern, dataStoreBuilder: dataStoreBuilder)
                }
                
            }
            .padding(AppConfig.UI.Padding.standard)
            .background(.background)
            .cornerRadius(AppConfig.UI.Corner.standard)
            .shadow(color: Color.black.opacity(AppConfig.UI.Opacity.light), radius: AppConfig.UI.Radius.small, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: AppConfig.UI.Corner.standard)
                    .stroke(Color.gray.opacity(AppConfig.UI.Opacity.medium), lineWidth: AppConfig.UI.Line.standard)
            )
        }
    }
}

// MARK: - Structure GridHeaderView
/// Displays the grid type headers (10x5, 5x10)
struct GridHeaderView: View {
    var body: some View {
        GridRow {
            Text("Grille")
                .frame(width: 75, alignment: .leading)
            ForEach(GridConfiguration.GridType.allCases, id: \.self) { gridType in
                Text("\(gridType.rows)x\(gridType.cols)")
                    .frame(width: 130, alignment: .center)
                    .gridCellColumns(2)
            }
        }
        .font(.subheadline.bold())
        .foregroundColor(.black)
    }
}

// MARK: - Structure GridSubHeaderView
/// Displays the "Lignes" and "Colonnes" subheaders
struct GridSubHeaderView: View {
    var body: some View {
        GridRow {
            Text("Configuration")
                .gridColumnAlignment(.leading)
                .frame(width: 75, alignment: .leading)
            
            ForEach(GridConfiguration.GridType.allCases) { _ in
                Text("Lignes")
                    .frame(width: 65, alignment: .center)
                Text("Colonnes")
                    .frame(width: 65, alignment: .center)
            }
        }
        .font(.subheadline)
    }
}
// MARK: - Structure GridDataRow
/// Displays a single row of distribution data for a specific pattern
struct GridDataRow: View {
    let pattern: GridConfiguration.Pattern
    let dataStoreBuilder: DataStoreBuilder
    
    var body: some View {
        GridRow {
            Text(pattern.rawValue)
                .gridColumnAlignment(.leading)
                .frame(width: 75, alignment: .leading)
            
            ForEach(GridConfiguration.GridType.allCases, id: \.self) { gridType in
                let analysis = GridConfiguration.analyzeGrid(
                    draws: dataStoreBuilder.draws,
                    gridType: gridType
                )
                Group {
                    Text("\(analysis.rows[pattern, default: 0])")
                        .frame(width: 65, alignment: .center)
                    Text("\(analysis.cols[pattern, default: 0])")
                        .frame(width: 65, alignment: .center)
                }
                .monospacedDigit()
            }
        }
    }
}
