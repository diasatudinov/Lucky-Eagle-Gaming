//
//  LEGTabBarView.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

struct LEGTabBarView: View {
    @State private var showGame = false
    @State private var showShop = false
    @State private var showAchievement = false
    @State private var showSettings = false
    @State private var showDailyTask = false

    var body: some View {
        ZStack {
            ZStack {
                
                Image(.playIconBgLEG)
                    .resizable()
                    .scaledToFit()
                HStack {
                    Image(.shopIconLEG1)
                        .resizable()
                        .scaledToFit()
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    
                    Image(.dailyTasksIconLEG)
                        .resizable()
                        .scaledToFit()
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    
                    Image(.playIconLEG)
                        .resizable()
                        .scaledToFit()
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 160:88)
                    
                    Image(.settingsIconLEG1)
                        .resizable()
                        .scaledToFit()
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 100:60)
                    
                    Image(.achievementsIconLEG1)
                        .resizable()
                        .scaledToFit()
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 100:60)
                }
            }.frame(maxWidth: .infinity).ignoresSafeArea()
        }
    }
}

#Preview {
    LEGTabBarView()
}
