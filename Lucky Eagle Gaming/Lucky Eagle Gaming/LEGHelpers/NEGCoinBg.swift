//
//  NEGCoinBg.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

struct NEGCoinBg: View {
    @StateObject var user = NEGUser.shared
    var height: CGFloat = NEGDeviceManager.shared.deviceType == .pad ? 100:50
    var body: some View {
        ZStack {
            Image(.coinsBgLEG)
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: NEGDeviceManager.shared.deviceType == .pad ? 40:25, weight: .black))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: -25, y: -4)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    NEGCoinBg()
}
