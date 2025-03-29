//
//  DeveloperToolsView.swift
//  EuroMillions
//
//  Created by Claude sur iCloud on 21/03/2025.
//

import SwiftUI

struct DeveloperToolsView: View {
    var body: some View {
        VStack {
            DataVerificationView()
                .border(Color.blue)
            
            PersistenceResetView()
                .border(Color.blue)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DeveloperToolsView()
}
