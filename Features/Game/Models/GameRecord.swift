//
//  GameRecord.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 13/03/2025.
//

import Foundation
import SwiftData

// MARK: - class GameRecord
@Model
final class GameRecord {
    
    // MARK: - Properties
    var id: UUID
    
    var ballsNumber: [Int]
    var orderIndex: Int
    var ballsNumberMatchCount: Int
    
    var starsNumber: [Int]
    var starsNumberMatchCount: Int
    var creationDate: Date
    
    // MARK: - Initialization
    init(id: UUID = UUID(),
         ballsNumber: [Int],
         orderIndex: Int,
         ballsNumberMatchCount: Int = 0,
         starsNumber: [Int],
         starsNumberMatchCount: Int = 0,
         creationDate: Date = Date()
    ) {
        self.id = id
        self.ballsNumber = ballsNumber
        self.orderIndex = orderIndex
        self.ballsNumberMatchCount = ballsNumberMatchCount
        self.starsNumber = starsNumber
        self.starsNumberMatchCount = starsNumberMatchCount
        self.creationDate = creationDate
    }
}
