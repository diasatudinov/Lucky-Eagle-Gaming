//
//  LEGLevelSelectView.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

struct LEGLevelSelectView: View {
    private let totalRounds = 10
    @Environment(\.presentationMode) var presentationMode
    @State var showGame = false
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                HStack(alignment: .top) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 100:50)
                    }
                    Spacer()
                    
                    LEGCoinBg()
                }.padding([.horizontal, .top])
                
                
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                    ForEach(1...totalRounds, id: \.self) { round in
                        ZStack {
                            Image(.levelBgLEG)
                                .resizable()
                                .scaledToFit()
                            
                            Text("\(round)")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(12)
                            
                        }.frame(height: LEGDeviceManager.shared.deviceType == .pad ? 200:110)
                            .onTapGesture {
                                showGame = true
                            }
                        
                    }
                }
                .padding(.horizontal, 16)
                Spacer()
            }
            
        }.background(
            ZStack {
                Image(.settingsViewBgLEG)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        )
        .fullScreenCover(isPresented: $showGame) {
            LEGGameView()
        }
    }
}

#Preview {
    NavigationStack {
        LEGLevelSelectView()
    }
}
