//
//  LEGAchievementsView.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

struct LEGAchievementsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = NEGAchievementsViewModel()
    @State private var currentIndex = 0
    var body: some View {
        ZStack {
            ZStack {
                Image(.achiBgLEG)
                    .resizable()
                    .scaledToFit()
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            currentIndex = max(currentIndex - 1, 0)
                        }
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 140:70)
                            .padding()
                            .opacity(currentIndex == 0 ? 0.3 : 1)
                    }
                    .disabled(currentIndex == 0)
                    
                    HStack(spacing: NEGDeviceManager.shared.deviceType == .pad ? 200:110) {
                        ForEach(currentItems) { achievement in
                            VStack {
                                Image(achievement.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 250:150)
                                    .opacity(achievement.isAchieved ? 1 : 0.5)                                    
                                
                            }.onTapGesture {
                                viewModel.achieveToggle(achievement)
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            currentIndex = min(currentIndex + 1, maxPageIndex)
                        }
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 140:70)
                            .padding()
                            .opacity(currentIndex == maxPageIndex ? 0.3 : 1)
                            .scaleEffect(x: -1, y: -1)
                    }
                    .disabled(currentIndex == maxPageIndex)
                }
            }
            .padding()
        }.frame(height: UIScreen.main.bounds.height / 1.3)
        
        
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 140:70)
                    }
                    Spacer()
                }.padding()
                Spacer()
                
                LEGTabBarView()
                    .offset(y: 10)
            }
        }.background(
            ZStack {
                Image(.settingsViewBgLEG)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                
            }
            
        )
    }
    
    private var currentItems: Array<NEGAchievement>.SubSequence {
        let start = currentIndex * 3
        let end = min(start + 3, viewModel.achievements.count)
        return viewModel.achievements[start..<end]
    }
    
    private var maxPageIndex: Int {
        max((viewModel.achievements.count - 1) / 3, 0)
    }
}

#Preview {
    LEGAchievementsView()
}
