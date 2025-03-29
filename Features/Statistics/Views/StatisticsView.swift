//
//  StatisticsView.swift
//
//  Created on 28/02/2025.
//

import SwiftUI


struct StatisticsView: View {
    
    // MARK: - Properties
    //@EnvironmentObject var dataStoreBuilder: DataStoreBuilder
    
    // Replace DataStoreBuilder with AppDataService
    @EnvironmentObject var appDataService: AppDataService

    
    
    @State private var showDistanceChart = false
    @State private var defaultPercentageValue = 80
    @State private var distanceMax = 0
    
    // For draggable charts
    @State private var chartPosition = CGPoint(x: 0, y: 0)
    @State private var initialChartPosition = CGPoint(x: 0, y: 0)
    
    let constants = AppConfig()
    
    // MARK: - Body
    var body: some View {

        // Main container
        VStack(spacing: AppConfig.UI.Spacing.large) {

            // Header Container
            VStack {
                // Header section with EuroMillions logo and title
                EuroMillionsHeader()
                    .frame(maxWidth: .infinity, alignment: .top)
                
                // Title
                Text("Statistiques Tirages")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppConfig.UI.Padding.large)
                
                
                /*if dataStoreBuilder.hasError {
                    Text(dataStoreBuilder.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                 */
                
                if appDataService.dataStore.hasError {
                    Text(appDataService.dataStore.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                 
            } // end of Header Container
            .padding()
            //.border(Color.black, width: AppConfig.UI.Border.standard)
            .background(Color.blue.opacity(AppConfig.UI.Opacity.light))
            .cornerRadius(AppConfig.UI.Corner.large)
            
            /*if dataStoreBuilder.isLoading {
                ProgressView("Loading statistics...")*/
                
                
            if appDataService.dataStore.isLoading {
                   ProgressView("Loading statistics...")
                
                
            } else {
                

                // Main Container
                /// This container is made of 2 secondary containers: The left and right containers.
                /// The left upper side container displays the historical draw table, the distance table and the weight table.
                /// The left lower side container displays a chart of the distribution of the historical draw numbers per column, based on thes sorted draw table.
                /// The rigtht side container computes statistics : such as parity, ...
                ///
                
                HStack(alignment: .top, spacing: AppConfig.UI.Spacing.none) {
                    
                    
                    // =====================================================================================
                    //  Left Container
                    
                    VStack() {
                        
                        // Upper left Container: Data Tables
                        VStack(){
                            // Column Containers
                            HStack(alignment: .top, spacing: AppConfig.UI.Spacing.large){
                                
                                // Column Container: Draw History content
                                DrawHistoryTable(dataStoreBuilder: appDataService.dataStore)
                                    .frame(width: AppConfig.Tables.fiveColumnsTableWidth, height: AppConfig.Tables.fiveColumnsTableHeight)
                                    //.border(Color.green, width: AppConfig.UI.Border.standard)
                                
                                
                                // Column Container: Distance content
                                DrawDistanceTable(dataStoreBuilder: appDataService.dataStore, distanceMax: $distanceMax)
                                    .frame(width: AppConfig.Tables.fiveColumnsTableWidth, height: AppConfig.Tables.fiveColumnsTableHeight)
                                    //.border(Color.green, width: AppConfig.UI.Border.standard)
                                
                                
                                // Column Container: Weight content
                                VStack {
                                    
                                    DrawWeightTable(dataStoreBuilder: appDataService.dataStore,distanceMax: $distanceMax)
                                        .frame(width: AppConfig.Tables.fiveColumnsTableWidth, height: AppConfig.Tables.fiveColumnsTableHeight)
                                        //.border(Color.green, width: AppConfig.UI.Border.standard)
                                    
                                } // end of Column Container: Weight content
                                .frame(width: AppConfig.Tables.fiveColumnsTableWidth, height: AppConfig.Tables.fiveColumnsTableHeight)
                                //.border(Color.green, width: AppConfig.UI.Border.standard)
                                
                                
                            } // end of Column Containers
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            //.border(Color.blue, width: AppConfig.UI.Border.standard)
                            
                        } // end of higher left container: Data Tables
                        .frame(maxWidth: .infinity, alignment: .leading)
                        //.border(Color.blue, width: AppConfig.UI.Border.standard)
                        .padding(AppConfig.UI.Padding.medium)

                        
                        //Spacer()
                        
                        // Lower left Container: Graphics
                        VStack() {
                            // Chart container : displays the distribution of the numbers per column
                            ColumnDistributionLineChart(
                                dataStoreBuilder: appDataService.dataStore,
                                distribution: calculateColumnDistributions(
                                    table: appDataService.dataStore.sortedDraws),
                                totalDraws: appDataService.dataStore.sortedDraws.count
                            )
                        } // end of lower left container
                        .padding(AppConfig.UI.Padding.medium)
                        
                    } // end of left Container
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //.border(Color.blue, width: AppConfig.UI.Border.standard)
                    .padding(AppConfig.UI.Padding.medium)
                    
                    Spacer()
                    
                    
                    
                    // =====================================================================================
                    // Right Container
                    //
                    // Main Container: Statistics Analysis
                  
                    VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.small){
                        
                        // statistics  container
                        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.none){
                            Text("Statistiques")
                                .font(.headline)
                                .padding(AppConfig.UI.Padding.small)
                            
                            // Number of occurences of identical number between 2 draws of the draws table
                            BaseStatView(
                                dataStoreBuilder: appDataService.dataStore,
                                analysis: IdenticalNumbersAnalysis()
                            )
                            .padding(AppConfig.UI.Padding.small)

                            // Odd/ even distribution
                            BaseStatView(
                                dataStoreBuilder: appDataService.dataStore,
                                analysis: OddEvenAnalysis()
                            )
                            .padding(AppConfig.UI.Padding.small)
                            
                            // Consecutive numbers distribution
                            BaseStatView(
                                dataStoreBuilder: appDataService.dataStore,
                                analysis: ConsecutiveNumbersAnalysis()
                            )
                            .padding(AppConfig.UI.Padding.small)
                            
                        } // end of Statistics Container
                        //.border(Color.black, width: 1)
                        
                        // Grid Container
                        VStack(alignment: .leading, spacing: AppConfig.UI.Spacing.none){
                            
                            // Grid distribution
                            GridDistributionView(dataStoreBuilder: appDataService.dataStore)
                            
                        } // end of Grid container
                        //.border(Color.red, width: 1)
                         
                    } // end of Right container
                    .frame(width: AppConfig.UI.Container.largeWidth, alignment: .leading)


                    //.border(Color.blue, width: 1)
                    .padding(AppConfig.UI.Padding.medium)
                    
                } // end of Main Container (HStack)
                .frame(maxWidth: .infinity, alignment: .leading)
                //.border(Color.red, width: AppConfig.UI.Border.standard)
                
            Spacer()
                
            } // end if
               
        } // end of Main Container
        
        /* DEBUG
        .onAppear {
            // print("StatisticsView appeared, triggering data load")
            Task {
                do {
                    print("Starting data load")
                    try await appDataStore.loadAllData()
                    print("Data loaded successfully")
                    print("Draws count after load: \(appDataStore.draws.count)")
                } catch {
                    print("Error loading data: \(error)")
                } // end of do
            } // end of Task
        } // end of onAppear
        */
        
        .onAppear {
            print("StatisticsView appeared")
            print(appDataService.getDiagnosticInfo())
        }
        
    } // end of body
    
} // end of struct
                
/*
// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        // This is an alternative way to preview that may work better
        let mockStore = DataStoreBuilder()
        mockStore.draws = [
            [1, 12, 23, 39, 45],
            [3, 7, 17, 21, 50],
            [5, 11, 27, 34, 41],
            [9, 16, 29, 37, 49]
        ]
        
        return StatisticsView()
            .environmentObject(mockStore)
    }
}
*/

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        // This is an alternative way to preview that may work better
        let mockAppDataService = AppDataService.shared
        
        return StatisticsView()
            .environmentObject(mockAppDataService)
    }
}
