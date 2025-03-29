//
//  WinProbabilityView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 10/03/2025.
//

import SwiftUI


/// This structure gives the probabilty of drawing n numbers out of k numbers
// MARK: - Structure GameProbability
struct WinProbability: View {
    
    /*
    // We'll make this an optional binding so it can be used without a parameter
    //@Binding var maxNumberValue: Int
    
    // Initialize with a default value from AppConfig
    init(maxNumberValue: Binding<Int> = .constant(AppConfig.Game.maxNumberValue)) {
        self._maxNumberValue = maxNumberValue
    }
    */
    
    // A state variable to track the max number value
    @State private var maxNumberValue = AppConfig.Game.maxNumberValue

    
    // MARK: - Function
    /// This function computes the combination of n out of m
    func combination(_ n: Int, _ m: Int) -> Int {
        if n > m { return 0 }
        var result = 1
        
        // Compute m * (m-1) * (m-2) ... for n terms
        for i in 0..<n {
            result *= (m - i)
            result /= (i + 1)
        }
        
        return result
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small) { // Added default spacing between VStack elements
            
            Text("Quelles sont les chances de tirer n bons numéros parmi \(AppConfig.Game.maxNumberValue) ?")
                .font(.title2)
                        
            HStack {
                Text("Nombre de chiffres retenus pour le tirage: ")
                    .font(.title3)
                    .frame(width: AppConfig.TextBox.extraLargeWidth)
                
                TextField("", value: $maxNumberValue, format: .number)
                    .frame(width: AppConfig.TextBox.smallWidth)
            } // end of HStack
            .padding(.leading, AppConfig.UI.Spacing.none)
            .padding(.bottom, AppConfig.UI.Spacing.small)
            
            
            ForEach(2...5, id: \.self) { i in
                HStack {
                    Text("\(i) bons N° - 1 chance sur : ")
                        .padding(.leading, AppConfig.UI.Padding.extraLarge)
                    Text("\(combination(i, AppConfig.Game.maxNumberValue))")
                        .frame(width: AppConfig.TextBox.standardWidth)
                } // end of HStack
            } // end of ForEach
        } // end of VStack
    } // end of body
} // end of struct


// MARK: - Preview
struct WinProbability_Previews: PreviewProvider {
    static var previews: some View {
        WinProbability()
            .frame(width: 500, height: 150)
            .border(Color.black, width: 1)
    }
}
