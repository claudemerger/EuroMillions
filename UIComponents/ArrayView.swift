//
//  ArrayView.swift
//  Loto2024
//
//  Created by Claude sur iCloud on 25/10/2024.
//

import SwiftUI

// MARK: - Generic Function
///This structure displays an array
struct ArrayView<T: CustomStringConvertible>: View {
    // Data can now be either [T] or [[T]]
    let data: Any
    
    // MARK: Properties
    // helper properties
    private var is2DArray: Bool {
        data is [[T]]
    } //end of i2DArray
    
    private var processedData: [[T]] {
        if is2DArray {
            return data as? [[T]] ?? []
        } else {
            // Convert 1D array to 2D array with single row
            return [(data as? [T] ?? [])]
        } // end of if
    } // end of processedData
    
    // MARK: - body
    var body: some View {
        
        // Main container
        VStack(spacing: AppConfig.UI.Spacing.none) {
            
            // Index row
            if let firstRow = processedData.first {
                HStack {
                    // Array container
                    ForEach(Array(0..<firstRow.count), id: \.self) { index in
                        
                        Text("\(index)")
                            .frame(width: AppConfig.Arrays.cellWidth, height: AppConfig.Arrays.cellHeight)
                            .background(AppConfig.Colors.alternateRowBackground)
                            .multilineTextAlignment(.center)
                            .id("header_\(index)")
                        
                    } // end of ForEach
                    
                } // end of Array container
                
            } // end of if
            
            // Data rows
            ForEach(Array(0..<processedData.count), id: \.self) { row in
                // Array container
                HStack {
                    
                    ForEach(Array(0..<processedData[row].count), id: \.self) { index in
                        Text("\(processedData[row][index].description)")
                            .frame(width: AppConfig.Arrays.cellWidth, height: AppConfig.Arrays.cellHeight)
                            .background(AppConfig.Colors.alternateRowBackground)
                            .multilineTextAlignment(.center)
                            .id("row\(row)_\(index)")
                    } // end of ForEach
                    
                } // end of Array container
                
            } // end of ForEach
            
        } // end of Main container
        .frame(maxWidth: .infinity, alignment: .leading)
       
    } // end of body
    
} // end of struct
    
// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Preview with 2D array
        let data2D: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 5)
        ArrayView<Int>(data: data2D)  // By explicitly specifying <Int>, we're telling the compiler what type T should be.
            .border(Color.blue, width: 1)
        
        // Preview with 1D array
        let data1D: [Int] = Array(repeating: 1, count: 6)
        ArrayView<Int>(data: data1D)  // By explicitly specifying <Int>, we're telling the compiler what type T should be.
            .border(Color.green, width: 1)
    } // end of VStack
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding()
    .background(Color.gray.opacity(0.1))
    .border(Color.blue, width: 1)
} // end of Preview

// MARK: - Comments
/// For integers
/// ArrayView<Int>(data: yourIntArray)

/// For strings
/// ArrayView<String>(data: yourStringArray)

/// For doubles
/// ArrayView<Double>(data: yourDoubleArray)
