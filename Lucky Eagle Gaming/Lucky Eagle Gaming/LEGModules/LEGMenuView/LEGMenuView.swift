//
//  LEGMenuView.swift
//  Lucky Eagle Gaming
//
//  Created by Dias Atudinov on 13.08.2025.
//

import SwiftUI

struct LEGMenuView: View {
    @State private var showGame = false
    @State private var showShop = false
    @State private var showAchievement = false
    @State private var showMiniGames = false
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showDailyTask = false
    
//    @StateObject var achievementVM = NEGAchievementsViewModel()
    @StateObject var settingsVM = NGSettingsViewModel()
//    @StateObject var shopVM = NEGShopViewModel()
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                
                VStack(spacing: 7) {
                    Spacer()
                    
                    Button {
                        showShop = true
                    } label: {
                        Image(.shopIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    }
                    
                    Button {
                        showAchievement = true
                    } label: {
                        Image(.achievementsIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    }
                    
                    Button {
                        showSettings = true
                    } label: {
                        Image(.settingsIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    }
                    
                    ZStack {
                        
                        Image(.playIconBgLEG)
                            .resizable()
                            .scaledToFit()
                        
                        Button {
                            showGame = true
                        } label: {
                            Image(.playIconLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 160:88)
                        }
                        
                    }.frame(maxWidth: .infinity).ignoresSafeArea()
                }
            }
        }.frame(maxWidth: .infinity)
        .background(
            ZStack {
                Image(.mainMenuBgLEG)
                    .resizable()
                    .scaledToFill()
            }.edgesIgnoringSafeArea(.all)
        )
        .fullScreenCover(isPresented: $showGame) {
//            NGRoundSelectionView()
        }
        .fullScreenCover(isPresented: $showAchievement) {
            LEGAchievementsView()
        }
        .fullScreenCover(isPresented: $showShop) {
//            NEGShopView(viewModel: shopVM)
        }
        .fullScreenCover(isPresented: $showSettings) {
            LEGSettingsView()
        }
        .fullScreenCover(isPresented: $showDailyTask) {
//            DailyRewardsView()
        }
    }
    
}

#Preview {
    LEGMenuView()
}
