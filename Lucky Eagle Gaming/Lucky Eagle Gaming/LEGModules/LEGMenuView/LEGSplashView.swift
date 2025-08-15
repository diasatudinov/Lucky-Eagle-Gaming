//
//  LEGSplashView.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

struct LEGSplashView: View {
    @State private var scale: CGFloat = 1.0
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    var body: some View {
        ZStack {
            ZStack {
                Image(.loaderBGLEG)
                    .resizable()
            }.edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 0) {
                Spacer()
                Image(.loaderLogoLEG)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                   
                Image(.loaderBorderLEG)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: scale
                    )
                    .onAppear {
                        scale = 0.8
                    }
            }
            
            
            
        }
        .onAppear {
            startTimer()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if progress < 1 {
                progress += 0.01
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    LEGSplashView()
}
