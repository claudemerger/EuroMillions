//
//  AppConfiguration.swift
//  EuroMillions
//
//  Created on 06/03/2025.
//

import SwiftUI

/// Central configuration system for the EuroMillions application
/// This file consolidates all application constants in a single location
/// for easier maintenance and consistency.
struct AppConfig {
    
    // MARK: - EuroMillions Default Parameters
    /// Contains default values for EuroMillions game parameters
    struct Game {
        ///
        static let maxNumberValue = 50
        static let drawSize = 5
        
        ///
        static let maxStarValue = 12
        static let starsSize = 2
    }
    
    /// Analysis and calculation parameters
    struct Analysis {
        /// Default percentage for distance calculations (80%)
        static let standardDistancePercentage: Double = 80.0
        
        /// Default percentage value as integer (80)
        static let standardPercentageValue: Int = 80
        
        /// Default chart grouping interval (5)
        static let chartGroupingInterval: Int = 5
        
        /// Default chart label interval (3)
        static let chartLabelInterval: Int = 3
        
        /// Threshold for considering a number as having high weight
        static let highWeightThreshold: Double = 1.2
        
        /// Threshold for considering a number as having low weight
        static let lowWeightThreshold: Double = 0.8
    }
    
    /// User interface dimensions, spacing, and layout
    struct UI {
        /// Spacing between UI elements
        struct Spacing {
            static let none: CGFloat = 0
            static let small: CGFloat = 5
            static let standard: CGFloat = 10
            static let medium: CGFloat = 15
            static let large: CGFloat = 20
        }
        
        /// Padding within UI elements
        struct Padding {
            static let none: CGFloat = 0
            static let small: CGFloat = 4
            static let standard: CGFloat = 8
            static let medium: CGFloat = 12
            static let large: CGFloat = 16
            static let extraLarge: CGFloat = 24
        }
        
        /// Border properties
        struct Border {
            static let thin: CGFloat = 0.5
            static let standard: CGFloat = 1
            static let thick: CGFloat = 2
        }
        
        /// Corner radius values
        struct Corner {
            static let small: CGFloat = 4
            static let standard: CGFloat = 8
            static let large: CGFloat = 12
        }
        
        /// Opacity values
        struct Opacity {
            static let light: CGFloat = 0.1
            static let medium: CGFloat = 0.2
            static let high: CGFloat = 0.8
        }
        
        /// Line thickness values
        struct Line {
            static let thin: CGFloat = 0.5
            static let standard: CGFloat = 1
            static let thick: CGFloat = 2
        }
        
        /// Radius values
        struct Radius {
            static let small: CGFloat = 2
            static let standard: CGFloat = 4
            static let large: CGFloat = 8
        }
        
        
        /// Container dimensions
        struct Container {
            static let minWidth: CGFloat = 100
            static let minHeight: CGFloat = 100
            
            static let smallWidth: CGFloat = 100
            static let smallHeight: CGFloat = 200
            
            static let standardWidth: CGFloat = 220
            static let standardHeight: CGFloat = 300
             
            static let largeWidth: CGFloat = 400
            static let largeHeight: CGFloat = 400
            
            /// Cell dimensions
            static let numberCellWidth: CGFloat = 25
            static let numberCellHeight: CGFloat = 25
            
            /// Text input dimensions
            //static let textBoxWidth: CGFloat = 100
            //static let textBoxHeight: CGFloat = 30
        }
    }
    
    /// Text box dimensions
    struct TextBox {
        static let smallWidth: CGFloat = 50
        static let smallheight: CGFloat = 20
        
        static let standardWidth: CGFloat = 100
        static let StandardHeight: CGFloat = 25

        static let mediumWidth: CGFloat = 150
        static let mediumHeight: CGFloat = 30
        
        static let largeWidth: CGFloat = 200
        static let largeHeight: CGFloat = 35
        
        static let extraLargeWidth: CGFloat = 300
        static let ExtraLargeHeight: CGFloat = 40
    }

    
    /// Table view configurations
    struct Tables {
        /// Draw history table dimensions
        static let drawHistoryWidth: CGFloat = 220
        static let drawHistoryHeight: CGFloat = 300
        
        /// Distance table dimensions
        static let distanceTableWidth: CGFloat = 220
        static let distanceTableHeight: CGFloat = 300
        
        /// Weight table dimensions
        static let weightTableWidth: CGFloat = 220
        static let weightTableHeight: CGFloat = 300
        
        /// Five columns table dimensions
        static let fiveColumnsTableWidth: CGFloat = 220
        static let fiveColumnsTableHeight: CGFloat = 575
        
        /// Row height
        static let standardRowHeight: CGFloat = 30
        
        /// Column widths
        struct Column {
            static let dateWidth: CGFloat = 90
            static let numbersWidth: CGFloat = 150
            static let starsWidth: CGFloat = 60
            
            static let numberWidth: CGFloat = 70
            static let valueWidth: CGFloat = 70
            static let avgWidth: CGFloat = 70
        }
    }
    
    /// Array View configurations
    struct Arrays {
        /// cell dimensions
        static let cellWidth: CGFloat = 40
        static let cellHeight: CGFloat = 15
        
        
    }
    
    /// Visual styling for lottery balls
    struct Balls {
        /// Regular number ball
        struct Number {
            static let size: CGFloat = 24
            static let opacity: CGFloat = 0.2
            static let color: Color = .blue
        }
        
        /// Star ball
        struct Star {
            static let size: CGFloat = 20
            static let opacity: CGFloat = 0.4
            static let color: Color = .yellow
        }
        
        /// Text inside balls
        static let textSize: CGFloat = 12
    }
    
    /// Font sizes throughout the application
    struct Fonts {
        static let title: CGFloat = 32
        static let headline: CGFloat = 18
        static let body: CGFloat = 14
        static let caption: CGFloat = 12
        static let small: CGFloat = 10
    }
    
    /// Color scheme
    struct Colors {
        static let headerBackground = Color.blue.opacity(0.1)
        static let alternateRowBackground = Color.gray.opacity(0.1)
        static let tableBorder = Color.gray.opacity(0.3)
        
        /// Status indication colors
        struct Status {
            static let positive = Color.green
            static let neutral = Color.primary
            static let negative = Color.red
        }
    }
}
