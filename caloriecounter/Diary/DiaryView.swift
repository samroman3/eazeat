//
//  DiaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    @State private var showingAddItemForm = false
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                TopBarView(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore, selectedDate: $dailyLogManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dailyLogManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {}, entryType: .diary)
                .frame(maxWidth: .infinity)
                Divider().background(AppTheme.lime)
                MealsView(dailyLogManager: dailyLogManager, mealSelectionViewModel: mealSelectionViewModel, nutritionDataStore: nutritionDataStore)
                    .frame(maxWidth: .infinity)
            }
            .background(AppTheme.prunes)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $mealSelectionViewModel.showingAddItemForm) {
                AddItemFormView(isPresented: $mealSelectionViewModel.showingAddItemForm, selectedDate: dailyLogManager.selectedDate, mealType: $mealSelectionViewModel.currentMealType, dataStore: NutritionDataStore(context: viewContext), onDismiss: {dailyLogManager.fetchDailyLogForSelectedDate()})
                    
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures NavigationView uses the full width on iPads
    }}

//#Preview {
//    DiaryView()
//}
