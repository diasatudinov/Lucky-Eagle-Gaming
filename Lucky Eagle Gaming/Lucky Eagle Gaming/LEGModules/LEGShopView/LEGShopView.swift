//
//  LEGShopView.swift
//  Lucky Eagle Gaming
//
//

import SwiftUI

struct LEGShopView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var user = LEGUser.shared
    @StateObject var viewModel = LEGShopViewModel()
    @State var category: LEGItemCategory = .skin
    var body: some View {
        ZStack {
            
            ZStack {
                Image(.shopBgLEG)
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Button {
                        category = viewModel.nextCategory(category: category)
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 140:70)
                            .padding()
                    }
                    ForEach(category == .skin ? viewModel.shopSkinItems:viewModel.shopBgItems, id: \.self) { item in
                        
                        ZStack {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                            
                            VStack {
                                Spacer()
                                if category == .skin {
                                    Button {
                                        viewModel.selectOrBuy(item, user: user, category: .skin)
                                    } label: {
                                        if viewModel.isPurchased(item, category: .skin) {
                                            ZStack {
                                                Image(.btnBgLEG)
                                                    .resizable()
                                                    .scaledToFit()
                                                
                                                Text(viewModel.isCurrentItem(item: item, category: .skin) ? "selected":"select")
                                                    .font(.caption)
                                                    .bold()
                                                    .foregroundStyle(.white)
                                            }.frame(height: LEGDeviceManager.shared.deviceType == .pad ? 70:40)
                                            
                                        } else {
                                            Image(.buyBtnLEG)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 70:40)
                                                .opacity(viewModel.isMoneyEnough(item: item, user: user, category: .skin) ? 1:0.6)
                                        }
                                        
                                    }
                                } else {
                                    if category == .background {
                                        Button {
                                            viewModel.selectOrBuy(item, user: user, category: .background)
                                        } label: {
                                            if viewModel.isPurchased(item, category: .background) {
                                                ZStack {
                                                    Image(.btnBgLEG)
                                                        .resizable()
                                                        .scaledToFit()
                                                    
                                                    Text(viewModel.isCurrentItem(item: item, category: .background) ? "selected":"select")
                                                        .font(.caption)
                                                        .bold()
                                                        .foregroundStyle(.white)
                                                }.frame(height: LEGDeviceManager.shared.deviceType == .pad ? 70:40)
                                                
                                            } else {
                                                Image(.buyBtnLEG)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 70:40)
                                                    .opacity(viewModel.isMoneyEnough(item: item, user: user, category: .background) ? 1:0.6)
                                            }
                                            
                                        }
                                    }
                                }
                            }.padding()
                        }
                        .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 350:230)
                    }
                    
                    Button {
                        category = viewModel.nextCategory(category: category)
                    } label: {
                        Image(.backIconLEG)
                            .resizable()
                            .scaledToFit()
                            .frame(height: LEGDeviceManager.shared.deviceType == .pad ? 140:70)
                            .padding()
                            .scaleEffect(x: -1, y: -1)
                    }
                }.padding(.top, 25)
                
            }
            .frame(height: UIScreen.main.bounds.height - 100)
            
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
                    LEGCoinBg()
                }.padding()
                
                Spacer()
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
    LEGShopView()
}
