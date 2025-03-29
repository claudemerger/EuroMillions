//
//  DrawingAlgorithmFromTable.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 21/03/2025.
//

import Foundation

// MARK: - Protocol DrawingAlgorithmFromTable
/// Defines the interface for lottery number generation algorithms

protocol DrawingAlgorithmFromTable {
    func generateDraw(table: [[Int]], count: Int) throws -> [Int]
    var description: String { get }
    var name: String { get }
}
