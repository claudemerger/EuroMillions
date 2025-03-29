//
//  EuroMillionsHeader.swift
//  EuroMillionsResults
//
//  Created on 28/02/2025.
//

import SwiftUI

/// Header view for the EuroMillions application
/// Displays a custom logo and title with a consistent design
/// Used across the application to provide visual identity
struct EuroMillionsHeader: View {
    var body: some View {
        HStack(spacing: 15) {
            // Custom EuroMillions logo
            // Uses a specialized view that creates the logo with a blue gradient
            // and white lottery balls
            EuroMillionsLogoView()
            
            // Title text section
            VStack(alignment: .leading, spacing: 4) {
                // Main title with the EuroMillions name
                Text("EuroMillions")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)
                
                // Subtitle describing the app's purpose
                Text("Results & Analysis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
            }
            
            // Push content to the left
            Spacer()
        }
        // Add padding around the content
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        // Create a rounded white background with shadow
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.bottom, 15)
    }
}

// MARK: - Preview

struct EuroMillionsHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EuroMillionsHeader()
                .padding()
                .previewLayout(.sizeThatFits)
        }
        .background(Color.gray.opacity(0.1))
    }
}
