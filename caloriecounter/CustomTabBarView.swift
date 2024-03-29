//
//  CustomTabBarView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @State private var selectedTab: Tab = .diary

    var body: some View {
        VStack {
            
            // Content based on selected tab
            switch selectedTab {
            case .diary:
                DiaryView()
            case .statistics:
                DailySummaryView(viewModel: DailySummaryViewModel(dailyLogManager: dailyLogManager))
            case .profile:
                ProfileView()
            }

            // Custom Tab Bar
            HStack(spacing: 50) {
                TabBarButton(icon: "square", selectedIcon: "square.fill", tab: .diary, selectedTab: $selectedTab, color: AppTheme.lime)
                TabBarButton(icon: "triangle", selectedIcon: "triangle.fill", tab: .statistics, selectedTab: $selectedTab, color: AppTheme.lavender)
                TabBarButton(icon: "circle", selectedIcon: "circle.fill", tab: .profile, selectedTab: $selectedTab, color: AppTheme.carrot)
                
            }
            .padding(.horizontal)
        }
        .background(AppTheme.prunes)
    }

    enum Tab {
        case diary, statistics, profile
    }
}

struct TabBarButton: View {
    let icon: String
    let selectedIcon: String
    let tab: CustomTabBarView.Tab
    @Binding var selectedTab: CustomTabBarView.Tab
    let color: Color

    var body: some View {
        Image(systemName: selectedTab == tab ? selectedIcon : icon)
            .foregroundColor(color)
            .imageScale(.medium)
            .font(.system(size: 25))
            .onTapGesture {
                withAnimation(.snappy) {
                    selectedTab = tab
                }
            }
    }
}

//Dummy Views


#Preview {
    CustomTabBarView()
}
