//
//  DataStructure.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 18/02/2025.
//

import Foundation

// MARK: - Data Structures

/// Represents a single draw record
public struct DrawRecord: Hashable, Identifiable,Sendable{
    public var id: Date { date }  // Using date as identifier since draws are unique per date
    public let date: Date
    public let numbers: [Int]
    
    public init(date: Date, numbers: [Int]) {
        self.date = date
        self.numbers = numbers
    }
}

/// Represents a star numbers record
public struct StarRecord: Hashable, Identifiable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let stars: [Int]
    
    public init(date: Date, stars: [Int]) {
        self.date = date
        self.stars = stars
    }
}

/// Represents a win amount record
public struct WinRecord: Hashable, Identifiable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let wins: [Double]
    
    public init(date: Date, wins: [Double]) {
        self.date = date
        self.wins = wins
    }
}

// In DataStructure.swift
public struct EuroMillionsData: Sendable {
    public let draws: [DrawRecord]
    public let stars: [StarRecord]
    public let wins: [WinRecord]
    
    public init(draws: [DrawRecord], stars: [StarRecord], wins: [WinRecord]) {
        self.draws = draws
        self.stars = stars
        self.wins = wins
    }
}
