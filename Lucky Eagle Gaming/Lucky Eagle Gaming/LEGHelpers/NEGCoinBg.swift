import SwiftUI

struct NEGCoinBg: View {
    @StateObject var user = NEGUser.shared
    var height: CGFloat = NEGDeviceManager.shared.deviceType == .pad ? 100:50
    var body: some View {
        ZStack {
            Image(.coinsBgNEG)
                .resizable()
                .scaledToFit()
            
            Text("\(user.money)")
                .font(.system(size: NEGDeviceManager.shared.deviceType == .pad ? 30:15, weight: .black))
                .foregroundStyle(.yellow)
                .textCase(.uppercase)
                .offset(x: -15)
            
            
            
        }.frame(height: height)
        
    }
}

#Preview {
    NEGCoinBg()
}