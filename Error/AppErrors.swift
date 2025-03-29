//
//  AppErrors.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 21/03/2025.
//

import Foundation


// MARK: - Enum GameError
/// Error types for the EuroMillions game
enum GameError: Error, LocalizedError {
    /// Invalid number of draws requested
    case invalidNumberOfDraws
    
    /// Numbers outside valid range
    case invalidNumberRange
    
    /// Algorithm not properly initialized
    case algorithmNotInitialized
    
    case invalidPreferredNumbers
    
    case generationFailed
    
    case insufficientPreferredNumbers
    
    case duplicateNumbers
    
    case numberOutOfRange
    
    case unfairDistribution
    
    case invalidAlgorithm
    
    case maxAttemptsExceeded
    
    
    ///
    var errorDescription: String? {
        
        switch self {
            
        case .algorithmNotInitialized:
            return "Drawing algorithm not properly initialized"
            
        case .invalidPreferredNumbers:
            return "La liste des numéros préférés n'est pas valide"
            
        case .invalidNumberOfDraws:
            return "Le nombre de tirages demandé n'est pas valide ou dépasse la taille de la liste"
            
        case .invalidNumberRange:
            return "La liste des numéros n'est pas valide ou contient des doublons"
            
        case .generationFailed:
            return "La génération des tirages a échoué"
            
        case .insufficientPreferredNumbers:
            return "La liste doit contenir au moins 20 numéros"
            
        case .duplicateNumbers:
            return "La liste contient des numéros en double"
            
        case .numberOutOfRange:
            return "Les numéros doivent être entre 1 et 49"
            
        case .unfairDistribution:
            return "La distribution pair/impair n'est pas équilibrée"
            
        case .invalidAlgorithm:
            return "L'algorithme sélectionné n'est pas valide"
            
        case .maxAttemptsExceeded:
            return "Le nombre d'essais maximum a été dépassé"
            
            
        }
    }
}
