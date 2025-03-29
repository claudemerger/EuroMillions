//
//  DrawingAlgorithmFromList.swift
//  EuroMillions
//
//  Created on 19/03/2025.
//

import Foundation


// MARK: - Protocol DrawingAlgorithmFromList
/// Defines the interface for lottery number generation algorithms

protocol DrawingAlgorithmFromList {
    func generateDraw(list: [Int], count: Int) throws -> [Int]
    var description: String { get }
    var name: String { get }
}
