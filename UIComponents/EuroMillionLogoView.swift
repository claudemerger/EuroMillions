//
//  EuroMillionsLogoView.swift
//  EuroMillionsResults
//
//  Created on 28/02/2025.
//

import SwiftUI

/// A custom logo view for the EuroMillions application
/// Creates a circular logo with a Euro symbol and lottery balls
/// Entirely constructed in SwiftUI for easy scaling and customization
struct EuroMillionsLogoView: View {
    var body: some View {
        ZStack {
            // Main circle background with blue gradient
            // Creates the primary visual element of the logo
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .cyan]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .gray.opacity(0.5), radius: 4, x: 2, y: 2)
            
            // Small background stars (decorative elements)
            // Randomly positioned within the circle to create visual interest
            ForEach(0..<7, id: \.self) { index in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: CGFloat.random(in: 3...5), height: CGFloat.random(in: 3...5))
                    .position(
                        x: CGFloat.random(in: 30...170),
                        y: CGFloat.random(in: 30...120)
                    )
            }
            
            // Euro Symbol (€)
            // Central element that indicates the European lottery
            Text("€")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .offset(y: -10)
            
            // Bottom row: Three lottery balls
            // Represents some of the main numbers in the draw
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                }
            }
            .offset(y: 40)
            
            // Middle row: Two lottery balls
            // Represents additional main numbers in the draw
            HStack(spacing: 16) {
                ForEach(0..<2, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                }
            }
            .offset(y: 22)
        }
        // Fixed size for the logo
        .frame(width: 90, height: 90)
    }
}

// MARK: - Preview

struct EuroMillionsLogoView_Previews: PreviewProvider {
    static var previews: some View {
        // Show the logo on both light and dark backgrounds
        VStack(spacing: 40) {
            // Preview on light background
            EuroMillionsLogoView()
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            
            // Preview on dark background
            EuroMillionsLogoView()
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
