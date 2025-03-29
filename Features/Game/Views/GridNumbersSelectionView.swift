
//  GridNumbersSelectionView.swift
//  EuroMillions
//
//  Created on 21/03/2025
//
import SwiftUI

/// This module displays a EuroMillions grid, in which the player is going to select the numbers for the draw.
/// The numbers are entered in a array (preferredNumbers)

// MARK: - struct PreferredNumbersView
struct EuroMillionsGridNumbersSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var playerSelectedNumbers: Set<Int>        // @State in DrawingView
    @State private var tempNumber: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // Define grid structure - 5 columns
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    
    // MARK: - body
    var body: some View {
        VStack(spacing: 20) {
            // Header section with count and info
            HStack {
                VStack(alignment: .leading) {
                    Text("Numéros sélectionnés: \(playerSelectedNumbers.count)/\(AppConfig.Game.maxNumberValue)")
                        .font(.headline)
                    Text("Minimum requis: 20 numéros")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // Clear all button
                Button("Effacer tout") {
                    playerSelectedNumbers.removeAll()
                }
            } // end of HStack
            .padding(.horizontal)
            
            // Numbers grid - organized by column
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<10) { row in
                        HStack(spacing: 12) {
                            ForEach(0..<5) { col in
                                let number = col * 10 + row + 1
                                if number <= 50 {
                                    NumberCell(
                                        number: number,
                                        isSelected: playerSelectedNumbers.contains(number),
                                        onTap: {
                                            toggleNumber(number)
                                        }
                                    )
                                } else {
                                    // Empty space for numbers > 50
                                    Color.clear.frame(width: 40, height: 40)
                                }
                            }
                        }
                    }
                } // end of VStack
                .padding()
            } // end of ScrollView
            
            // Stats section
            VStack(alignment: .leading, spacing: 8) {
                Text("Statistiques:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    StatView(
                        label: "Pairs",
                        value: playerSelectedNumbers.filter { $0 % 2 == 0 }.count
                    )
                    StatView(
                        label: "Impairs",
                        value: playerSelectedNumbers.filter { $0 % 2 != 0 }.count
                    )
                }
            } // end of VStack
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        } // end of VStack
        .frame(minWidth: 600, minHeight: 720)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Valider") {
                    validateAndDismiss()
                }
            }
        } // end of ToolBar
        .alert("Erreur", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        } // end of Alert
        
    } // end of body
    
    
    // MARK: - Helpers
    
    private func toggleNumber(_ number: Int) {
        if playerSelectedNumbers.contains(number) {
            playerSelectedNumbers.remove(number)
            //print("📍 PreferredNumbersView - Removed number:", number, "Current set:", preferredNumbers)
        } else {
            playerSelectedNumbers.insert(number)
            //print("📍 PreferredNumbersView - Added number:", number, "Current set:", preferredNumbers)
        }
    } // end of func toggleNumber
    
    private func validateAndDismiss() {
        //print("📍 PreferredNumbersView - validateAndDismiss - Current numbers:", preferredNumbers)
        // Minimum 20 numbers required
        if playerSelectedNumbers.count < 20 {
            errorMessage = "La liste doit contenir au moins 20 numéros"
            showError = true
            return
        }
        dismiss()
    }
}

// MARK: - NUmberCell

struct NumberCell: View {
    let number: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("\(number)")
                .font(.system(.body, design: .rounded))
                .bold()
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
    }
}
// MARK: - StatsView
struct StatView: View {
    let label: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(value)")
                .font(.title3)
                .bold()
        }
    }
}

// MARK: - Preview
#Preview {
    EuroMillionsGridNumbersSelectionView(playerSelectedNumbers: .constant([]))
}
