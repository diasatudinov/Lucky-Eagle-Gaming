//
//  LEGSettingsView.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

struct LEGSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var settingsVM = NGSettingsViewModel()
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    
                    Image(.setingsBgLEG)
                        .resizable()
                        .scaledToFit()
                    
                    VStack {
                        
                        HStack {
                            
                            Image(.musicTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                            Image(.onTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                            
                        }
                        
                        VStack(alignment: .leading) {
                            Image(.volumeTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                            
                            Image(settingsVM.soundEnabled ?.volumeOnLEG : .volumeOffLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                                .onTapGesture {
                                    withAnimation {
                                        settingsVM.soundEnabled.toggle()
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading) {
                            Image(.btightnessTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                            
                            Image(settingsVM.brigthnessEnabled ? .volumeOnLEG : .volumeOffLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                                .onTapGesture {
                                    withAnimation {
                                        settingsVM.brigthnessEnabled.toggle()
                                    }
                                }
                               
                        }
                        
                        HStack {
                            Image(.languageTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                            
                            Image(.englishTextLEG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: NEGDeviceManager.shared.deviceType == .pad ? 50:35)
                               
                        }
                    }.padding(.top)
                }.frame(height: UIScreen.main.bounds.height / 1.1)
                
            }.padding()
            
            
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
        }.frame(maxWidth: .infinity)
        .background(
            ZStack {
                Image(.settingsViewBgLEG)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    
                
            }
            
        )
    }
}

#Preview {
    LEGSettingsView()
}
