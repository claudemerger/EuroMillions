//
//  PrimaryButtonStyle.swift
//  EuroMillionsResults
//
//  Created on 28/02/2025.
//

import SwiftUI

/// Custom button style used throughout the EuroMillions application
/// Provides a consistent visual style for primary action buttons
/// Features:
/// - Blue background with rounded corners
/// - White text for good contrast
/// - Scale animation when pressed
/// - Slightly darker color when pressed
struct PrimaryButtonStyle: ButtonStyle {
    /// Creates the visual representation of the button
    /// - Parameter configuration: The button configuration provided by SwiftUI
    /// - Returns: A view that represents the styled button
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Add padding around the button content
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            // Create a blue background that darkens when pressed
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            )
            // White text for good contrast against blue
            .foregroundColor(.white)
            // Subtle scale animation when pressed
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            // Smooth animation for state changes
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    /// Default initializer
    /// Creates a new instance of the button style
    public init() {}
}

// MARK: - Example Usage

/// Example of how to use the PrimaryButtonStyle
struct PrimaryButtonStyle_Example: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Primary Action") {
                print("Button tapped")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Another Action") {
                print("Another action")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            // Example of disabled state
            Button("Disabled Action") {
                print("This won't be called")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
            .opacity(0.6)
        }
        .padding()
    }
}

// MARK: - Preview

struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButtonStyle_Example()
            .previewLayout(.sizeThatFits)
    }
}
