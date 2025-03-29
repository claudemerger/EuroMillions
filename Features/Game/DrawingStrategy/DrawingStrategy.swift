//
//  DrawingStrategy.swift
//  EuroMillions
//
//  Created on 21/03/2025.
//

import Foundation

// MARK: - Enum DrawingStrategy
/// Represents available drawing algorithms
///
enum DrawingStrategy: String, CaseIterable, Identifiable {
    ///
    case simple = "Tirage aléatoire à partir d'une liste de 50 numéros"
    ///
    case userSelectedNumbers = "Tirage aléatoire sur Grille"
    ///
    case fullColumnWeighted = "Tirage aléatoire par colonne - Table des tirages complète"
    ///
    case reducedColumnWeighted = "Tirage aléatoire par colonne - Table des tirages réduite"
    ///
    case columnDrawingHistory = "Tirage aléatoire par colonne à partir de l'historique des tirages du dernier N° sorti"
    
    //case mappingBased = "Tirage basé sur l'analyse des distances et fréquences"
    
    
    var id: String { self.rawValue }
    
    
    var description: String {
        
        switch self {
            
        case .simple:
            return "Génère les tirages à partir de la liste des 50 numéros du loto"
        
        case .userSelectedNumbers:
            return "Génère les tirages à partir d'une liste de numéros sélectionnés par le joueur sur une grille"
        
        case .fullColumnWeighted:
            return "Génère les N° des tirages à partir des données des colonnes extraites de la table des tirages complète"
        
        case .reducedColumnWeighted:
            return "Génère les N° des tirages à partir des données des colonnes extraites de la table des tirages réduite"
        
        case .columnDrawingHistory:
            return "Génère les N° des tirages à partir de l'historique des tirages du dernier N° sorti"
        
        //case .mappingBased:
            //return "Génère les tirages en filtrant les numéros selon leur distance d'apparition et leur fréquence"
        }
    }
}
