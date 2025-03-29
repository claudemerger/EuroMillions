//
//  EuroMillionsModel.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 19/03/2025.
//

import Foundation


///This enhanced domain model includes:
/// Source pools: Where the numbers/stars were drawn from (which could be reduced from the full range)
/// Applied filters: Details of which filters were used with their parameters
/// Game parameters: A separate structure capturing the generation algorithm, preferred numbers/stars, and filter configuration
/// Game table: A collection of combinations generated with specific parameters
///
/// This structure allows  to:
/// Track exactly how each combination was generated
/// Store the complete configuration used (algorithm, filters, etc.)
/// Group combinations into named tables
/// Maintain a history of different generation strategies
///
// A simpler approach to handling various types in a Codable context
enum CodableValue: Codable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    
    var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }
    
    var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let value) = self { return value }
        return nil
    }
    
    var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}


//MARK: - EuroMillions model implementation

struct EuroMillionsCombination: Codable, Identifiable, Hashable {
   
    // MARK: - Properties
    var id: UUID
    var ballNumbers: [Int]  // 5 numbers from 1-50
    var starNumbers: [Int]    // 2 stars from 1-12
    var creationDate: Date
    var generationStrategy: String
    var orderIndex: Int
    //let appliedFilters: [AppliedFilter]
    //let sourceNumbers: [Int] // The pool of numbers the combination was drawn from
    //let sourceStars: [Int]   // The pool of stars the combination was drawn from
    //let metadata: [String: String]  // Additional information about the combination
    
    // Optional fields for future use
    //var mainNumbersMatchCount: Int = 0
    //var starNumbersMatchCount: Int = 0
    // modify CoddingKeys when adding future properties
    
    // MARK: - init
    
    init(
        id: UUID = UUID(),
        ballNumbers: [Int],
        starNumbers: [Int],
        creationDate: Date = Date(),
        generationStrategy: String,
        orderIndex: Int = 0
        //appliedFilters: [AppliedFilter] = [],
        //sourceNumbers: [Int] = Array(1...50),
        //sourceStars: [Int] = Array(1...12),
        //metadata: [String: String] = [:]
    ) {
        self.id = id
        self.ballNumbers = ballNumbers.sorted()
        self.starNumbers = starNumbers.sorted()
        self.creationDate = creationDate
        self.generationStrategy = generationStrategy
        self.orderIndex = orderIndex
        //self.appliedFilters = appliedFilters
        //self.sourceNumbers = sourceNumbers
        //self.sourceStars = sourceStars
        //self.metadata = metadata
    }
    
    // MARK: - Enum
    // Add encoding/decoding support for AppliedFilter
    enum CodingKeys: String, CodingKey {
        //case id, ballNumbers, starNumbers, creationDate, generationStrategy, appliedFilters, sourceNumbers, sourceStars, metadata
        case id, ballNumbers, starNumbers, creationDate, generationStrategy, orderIndex
    }
   
    // Validate a EuroMillions combination
    var isValid: Bool {
        guard ballNumbers.count == 5, starNumbers.count == 2 else { return false }
        
        let validNumbers = ballNumbers.allSatisfy { $0 >= 1 && $0 <= 50 }
        let validStars = starNumbers.allSatisfy { $0 >= 1 && $0 <= 12 }
        
        return validNumbers && validStars
    }
}

// MARK: -
// Represents a filter that was applied during combination generation
struct AppliedFilter: Hashable, Codable {
    let id: String
    let name: String
    let parameters: [String: CodableValue]
    
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: AppliedFilter, rhs: AppliedFilter) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    // Explicit Codable implementation is not needed as long as all properties are Codable
}

// Game parameters used to generate a set of combinations
struct GameParameters: Identifiable, Codable {
    let id: UUID
    let name: String
    let algorithm: String
    let numberOfCombinations: Int
    let enabledFilters: [FilterConfiguration]
    let preferredNumbers: [Int]
    let preferredStars: [Int]
    let creationDate: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        algorithm: String,
        numberOfCombinations: Int,
        enabledFilters: [FilterConfiguration] = [],
        preferredNumbers: [Int] = [],
        preferredStars: [Int] = [],
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.algorithm = algorithm
        self.numberOfCombinations = numberOfCombinations
        self.enabledFilters = enabledFilters
        self.preferredNumbers = preferredNumbers
        self.preferredStars = preferredStars
        self.creationDate = creationDate
    }
}

// Configuration for a specific filter
struct FilterConfiguration: Identifiable, Hashable, Codable {
    
    let id: String
    let name: String
    let isEnabled: Bool
    let parameters: [String: Double]
}

// Represents a collection of combinations generated with specific parameters
struct GameTable: Identifiable, Codable{
    
    let id: UUID
    let name: String
    let combinations: [EuroMillionsCombination]
    let parameters: GameParameters
    let creationDate: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        combinations: [EuroMillionsCombination],
        parameters: GameParameters,
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.combinations = combinations
        self.parameters = parameters
        self.creationDate = creationDate
    }
}

// MARK: - Helper

// Helper type to make [String: Any] codable
struct CodableAny: Codable, Hashable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        // Basic hash implementation for supported types
        if let string = value as? String {
            hasher.combine(string)
        } else if let number = value as? Double {
            hasher.combine(number)
        } else if let bool = value as? Bool {
            hasher.combine(bool)
        }
    }
    
    static func == (lhs: CodableAny, rhs: CodableAny) -> Bool {
        // Basic equality for supported types
        if let lhsString = lhs.value as? String, let rhsString = rhs.value as? String {
            return lhsString == rhsString
        } else if let lhsDouble = lhs.value as? Double, let rhsDouble = rhs.value as? Double {
            return lhsDouble == rhsDouble
        } else if let lhsBool = lhs.value as? Bool, let rhsBool = rhs.value as? Bool {
            return lhsBool == rhsBool
        }
        return false
    }
    
    // Codable implementation
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    enum ValueType: String, Codable {
        case string, int, double, bool, array, dictionary, null
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch value {
        case let string as String:
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(string, forKey: .value)
        case let int as Int:
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(int, forKey: .value)
        case let double as Double:
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(double, forKey: .value)
        case let bool as Bool:
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(bool, forKey: .value)
        case let array as [Any]:
            try container.encode(ValueType.array, forKey: .type)
            try container.encode(array.map { CodableAny($0) }, forKey: .value)
        case let dict as [String: Any]:
            try container.encode(ValueType.dictionary, forKey: .type)
            try container.encode(dict.mapValues { CodableAny($0) }, forKey: .value)
        default:
            try container.encode(ValueType.null, forKey: .type)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)
        
        switch type {
        case .string:
            value = try container.decode(String.self, forKey: .value)
        case .int:
            value = try container.decode(Int.self, forKey: .value)
        case .double:
            value = try container.decode(Double.self, forKey: .value)
        case .bool:
            value = try container.decode(Bool.self, forKey: .value)
        case .array:
            let decodedArray = try container.decode([CodableAny].self, forKey: .value)
            value = decodedArray.map { $0.value }
        case .dictionary:
            let decodedDict = try container.decode([String: CodableAny].self, forKey: .value)
            value = decodedDict.mapValues { $0.value }
        case .null:
            value = NSNull()
        }
    }
}
