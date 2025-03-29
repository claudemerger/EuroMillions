#EuroMillions Application

This application is intended to give a player all the information to play the EuroMillions Game.
It has 4 main functions
1. compare a game/games to a draw and compute the win/wins
2. compute statistics based on draws history
3. compute games for the next draw
4. backtest games strategies

General info:
For each lottery game, such as EuroMillions, Loto, etc, the FDJ maintains a section on its web site where it stores draws record files for the past and current periods. Records of these files varies sligthly according to the changes made to the game for that period. 
Another program (EuroMillionsDownloader) has processed the past draws files  and generated a csv file with all the preceding draws records period in chronological order. This file, called EuroMillionsHistoricalData, will be used at program start up to build the EuroMillionsDataBase which will hold all records from first draw to the last one.

Start-up:
At start-up the EuroMillions Application will load the current period draws record file and process it to get the EuroMillionsCurrentData table, compatible with the EuroMillionsHistoricalData format. It will then load the EuroMillionsHistoricalData file and merge the records to get the EuroMillionsDataBase.
The draw record does not contain all the information from the original FDJ file, but just the necessary information needed for the application (draw day, draw date, draws data, stars data and wins data)

From this database it will generate all the tables used in the program and store them in a DataStore.
The DataStore will store: draws, stars, wins, sortedDraws, sortedStars, Distance and Weight tables (arrays).

App Version 0:
This version will 
1. download the current draws records file from the FDJ web site
2. unzip the file
3. remove all the unnecessary fields of the csv file, just to keep, the day field, the date field, the 5 balls field in chronological order, the 2 stars field in chronological order, the ?? wins field.
4. load the EuroMillionsHistoricalData from the Resources folder
5. merge EuroMillionsHistoricalData with EuroMillionsCurrentData and call the resulting table EuroMillionsDataBase
6. Generate the draws, stars, wins, sortedDraws, sortedStars table and store them in the DataStore.
7. print the draws table to check that the app is doing what version0 is working as described
