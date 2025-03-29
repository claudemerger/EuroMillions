//
//  SwiftDataModels.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//

// File: DataPersistence/SwiftDataModels.swift

import Foundation
import SwiftData

@Model
final class PersistentEuroMillionsCombination {
    @Attribute(.unique) var id: UUID
    var encodedData: Data // Will store the entire combination as JSON data
    var creationDate: Date // Duplicate for efficient querying
    var generationStrategy: String // Duplicate for efficient querying
    var orderIndex: Int
    
    init(id: UUID = UUID(), data: Data, creationDate: Date, generationStrategy: String, orderIndex: Int = 0) {
        self.id = id
        self.encodedData = data
        self.creationDate = creationDate
        self.generationStrategy = generationStrategy
        self.orderIndex = orderIndex
    }
}
