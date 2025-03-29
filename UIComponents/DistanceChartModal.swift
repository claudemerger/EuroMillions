//
//  DistanceChartModal.swift
//
//  Created by Claude sur iCloud on 04/03/2025.
//

import SwiftUI


struct DistanceChartModal: View {
    // Data for the chart
    let distanceData: [Int: Int]
    
    // Binding to control visibility from parent
    @Binding var isPresented: Bool
    
    // State for drag gesture
    @State private var offset = CGSize.zero
    @State private var position = CGSize.zero
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Chart content
            VStack {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding([.top, .trailing], 10)
                }
                
                // The actual chart view
                DistanceChartView(distanceData: distanceData)
            }
            .frame(width: 600)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .offset(x: position.width + offset.width, y: position.height + offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        position.width += offset.width
                        position.height += offset.height
                        offset = .zero
                    }
            )
        }
    }
}

// MARK: -
/*
#Preview {
    DistanceChartModal()
}
*/
