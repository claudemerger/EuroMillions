//
//  SwiftDataGameRepository.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//
// File: DataPersistence/SwiftDataGameRepository.swift

import Foundation
import SwiftData

// MARK: - Class Swift Data Repository
@MainActor
class SwiftDataGameRepository: GamePersistenceProtocol {
    typealias GameCombinationType = EuroMillionsCombination
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() throws {
        let schema = Schema([PersistentEuroMillionsCombination.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        self.modelContext = ModelContext(modelContainer)
    }
    
    // MARK: - Conversion Methods
    
    private func toPersistentModel(_ combination: EuroMillionsCombination) throws -> PersistentEuroMillionsCombination {
        // Encode the entire combination as JSON data
        let data = try encoder.encode(combination)
        
        return PersistentEuroMillionsCombination(
            id: combination.id,
            data: data,
            creationDate: combination.creationDate,
            generationStrategy: combination.generationStrategy,
            orderIndex: combination.orderIndex
        )
    }
    
    /*
    private func toDomainModel(_ persistentModel: PersistentEuroMillionsCombination) throws -> EuroMillionsCombination {
        // Decode the JSON data back to a combination
        return try decoder.decode(EuroMillionsCombination.self, from: persistentModel.encodedData)
    }
    */
    
    private func toDomainModel(_ persistentModel: PersistentEuroMillionsCombination) throws -> EuroMillionsCombination {
        // Decode the JSON data back to a combination
        return try decoder.decode(EuroMillionsCombination.self, from: persistentModel.encodedData)
    }
    
    // MARK: - Protocol Implementation
    
    func saveGames(_ combinations: [EuroMillionsCombination]) async throws {
        // Convert domain models to persistent models
        for combination in combinations {
            let persistentModel = try toPersistentModel(combination)
            modelContext.insert(persistentModel)
        }
        
        try modelContext.save()
    }
    
    func loadGames() async throws -> [EuroMillionsCombination] {
        // Create a descriptor with sorting
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.sortBy = [SortDescriptor(\.orderIndex, order: .forward)]  

        
        let persistentModels = try modelContext.fetch(descriptor)
        
        // Convert persistent models to domain models
        return try persistentModels.compactMap { persistentModel in
            try? toDomainModel(persistentModel)
        }
    }
    
    func deleteAllGames() async throws {
        try modelContext.delete(model: PersistentEuroMillionsCombination.self)
    }
    
    func getGameCount() async throws -> Int {
        let descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        return try modelContext.fetchCount(descriptor)
    }
    
    func queryGamesByDateRange(startDate: Date, endDate: Date) async throws -> [EuroMillionsCombination] {
        let predicate = #Predicate<PersistentEuroMillionsCombination> { model in
            model.creationDate >= startDate && model.creationDate <= endDate
        }
        
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.predicate = predicate
        
        let persistentModels = try modelContext.fetch(descriptor)
        return try persistentModels.compactMap { try? toDomainModel($0) }
    }
    
    func queryGamesByStrategy(strategy: String) async throws -> [EuroMillionsCombination] {
        let predicate = #Predicate<PersistentEuroMillionsCombination> { model in
            model.generationStrategy == strategy
        }
        
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.predicate = predicate
        
        let persistentModels = try modelContext.fetch(descriptor)
        return try persistentModels.compactMap { try? toDomainModel($0) }
    }
    
    // Add this method to your SwiftDataGameRepository class
    func getHighestOrderIndex() async throws -> Int {
        var descriptor = FetchDescriptor<PersistentEuroMillionsCombination>()
        descriptor.sortBy = [SortDescriptor(\.orderIndex, order: .reverse)]
        descriptor.fetchLimit = 1
        
        let results = try modelContext.fetch(descriptor)
        return results.first?.orderIndex ?? -1
    }
}
