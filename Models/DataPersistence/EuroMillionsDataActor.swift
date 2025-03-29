///
//  EuroMilliionsDataActor.swift
//  EuroMillions
//
//  Created on 21/03/2025.
//

// EuroMillionsDataActor.swift
import Foundation
import SwiftData

import Foundation
import SwiftData

@MainActor
class EuroMillionsDataActor {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    
    // Save games
    func saveGames(_ combinations: [EuroMillionsCombination]) async throws {
        // Convert domain models to persistent models
        for combination in combinations {
            let persistentModel = try toPersistentModel(combination)
            modelContext.insert(persistentModel)
        }
        
        try modelContext.save()
    }
    
    // Load games with proper sorting
    func loadGames() async throws -> [EuroMillionsCombination] {
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.sortBy = [SortDescriptor(\.orderIndex, order: .forward)]
        
        let persistentModels = try modelContext.fetch(descriptor)
        return persistentModels.compactMap { persistentModel in
            try? toDomainModel(persistentModel)
        }
    }
    
    // Delete all games
    func deleteAllGames() async throws {
        try modelContext.delete(model: PersistentEuroMillionsCombination.self)
    }
    
    // Get highest order index
    func getHighestOrderIndex() async throws -> Int {
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.sortBy = [SortDescriptor(\.orderIndex, order: .reverse)]
        descriptor.fetchLimit = 1
        
        let results = try modelContext.fetch(descriptor)
        return results.first?.orderIndex ?? -1
    }
    
    // Helper methods
    private func toPersistentModel(_ combination: EuroMillionsCombination) throws -> PersistentEuroMillionsCombination {
        let encoder = JSONEncoder()
        let data = try encoder.encode(combination)
        
        return PersistentEuroMillionsCombination(
            id: combination.id,
            data: data,
            creationDate: combination.creationDate,
            generationStrategy: combination.generationStrategy,
            orderIndex: combination.orderIndex
        )
    }
    
    private func toDomainModel(_ persistentModel: PersistentEuroMillionsCombination) throws -> EuroMillionsCombination {
        let decoder = JSONDecoder()
        return try decoder.decode(EuroMillionsCombination.self, from: persistentModel.encodedData)
    }
}
