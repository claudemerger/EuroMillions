//
//  PersistenceResetView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 21/03/2025.
//

import SwiftUI

struct PersistenceResetView: View {
    var body: some View {
        VStack {
            
            Text("Reset Persistence Store")
            
            Button("Reset Persistent Store") {
                resetPersistentStore()
                // Optionally restart the app or clear in-memory data
                //gameInstance.loadedGames = []
            } // end of button Reset Persistence
            .foregroundColor(.red)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
        } // end of VStack
        .frame(width: 500, height: 200)
        .border(Color.blue, width: 1)
        
    } // end of body
} // end of struct

#Preview {
    PersistenceResetView()
}
