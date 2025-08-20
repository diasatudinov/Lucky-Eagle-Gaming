//
//  LEGCoinBg.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

struct LEGCoinBg: View {
    @StateObject var user = LEGUser.shared
    var height: CGFloat = LEGDeviceManager.shared.deviceType == .pad ? 100:50
    var body: some View {
        ZStack {
            Image(.coinsBgLEG)
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: LEGDeviceManager.shared.deviceType == .pad ? 40:25, weight: .black))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: -25, y: -4)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    LEGCoinBg()
}
