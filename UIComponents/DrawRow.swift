//
//  DrawRow.swift
//
//  Created by Claude sur iCloud on 04/03/2025.
//

import SwiftUI


// MARK: - Draw Row

/// Individual row for the draw history table
/// Displays a single draw's numbers and stars
struct DrawRow: View {
    // MARK: - Properties
    
    var numbers: [Int]
    var isAlternate: Bool = false
    
    // MARK: - Body
    
    var body: some View {
            HStack(spacing: AppConfig.UI.Spacing.small) {
                // Change this ForEach to use enumerated() for unique IDs
                ForEach(Array(numbers.enumerated()), id: \.offset) { index, number in
                    Text("\(number)")
                        .font(.system(size: AppConfig.Fonts.caption, weight: .bold))
                        .frame(width: AppConfig.UI.Container.numberCellWidth, height: AppConfig.UI.Container.numberCellHeight)
                        .background(Color.blue.opacity(AppConfig.UI.Opacity.light))
                        .cornerRadius(AppConfig.UI.Corner.large)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppConfig.UI.Padding.standard - 2)
            .padding(.vertical, AppConfig.UI.Padding.standard / 2)
        }
    
}

// MARK: - Preview
