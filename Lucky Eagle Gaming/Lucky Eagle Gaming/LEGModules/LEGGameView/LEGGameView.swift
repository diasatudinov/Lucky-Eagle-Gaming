//
//  LEGGameView.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI
import SpriteKit

struct LEGGameView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var gameScene: LEGGameScene = {
        let scene = LEGGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        
        return scene
    }()
    @State var showRepOverlay = true
    @State private var repNum = 1
    @State var gameWin: Bool?
    var body: some View {
        ZStack {
            if LEGDeviceManager.shared.deviceType == .pad {
                Image(.gameBgLEG)
                    .resizable()
                    .ignoresSafeArea()
            } else {
                Image(.gameBgLEG)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            }
            
                
                
            LEGSpriteViewContainer(
                scene: gameScene,
                gameWin: $gameWin,
                showRepOverlay: $showRepOverlay,
                repNum: $repNum
            ).ignoresSafeArea()
            
            if showRepOverlay {
                showReps(repNum: repNum)
                   
            }
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 140:70)
                    }
                    Spacer()
                }.padding()
                Spacer()
            }
            
            if let gameWin = gameWin {
                if gameWin {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        ZStack {
                            Image(.winBgLEG)
                                .resizable()
                                .scaledToFit()
                            
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Button {
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        Image(.restartBtnLEG)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                    }
                                    
                                    Button {
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        Image(.nextBtnLEG)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                    }
                                    
                                    
                                    Image(.restartBtnLEG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .opacity(0)
                                }.offset(y: 40)
                            }
                        }.frame(height: UIScreen.main.bounds.height - 100)
                    }
                } else {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        ZStack {
                            Image(.loseBgLEG)
                                .resizable()
                                .scaledToFit()
                            
                            HStack {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(.restartBtnLEG)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                }
                                
                                
                                Image(.restartBtnLEG)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .opacity(0)
                            }.offset(y: 120)
                            
                        }.frame(height: UIScreen.main.bounds.height)
                    }
                }
            }
            
            
        } .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                    showRepOverlay = false
            }
        }
        .onChange(of: showRepOverlay) { newValue in
            if newValue {
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                        showRepOverlay = false
                }
            }
        }
    }
    
    @ViewBuilder func showReps(repNum: Int) -> some View {
        VStack {
            Spacer()
            Image("rep\(repNum)LEG")
                .resizable()
                .scaledToFit()
        }
    }
    
}

#Preview {
    LEGGameView()
}
