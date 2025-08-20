//
//  LEGShopViewModel.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI


final class LEGShopViewModel: ObservableObject {
    // MARK: – Shop catalogues
    @Published var shopBgItems: [LEGItem] = [
        LEGItem(name: "bg2", image: "bgImage2LEG", icon: "gameBgIcon2LEG", price: 100),
        LEGItem(name: "bg1", image: "bgImage1LEG", icon: "gameBgIcon1LEG", price: 100),
        LEGItem(name: "bg3", image: "bgImage3LEG", icon: "gameBgIcon3LEG", price: 100),
    ]
    
    @Published var shopSkinItems: [LEGItem] = [
        LEGItem(name: "skin2", image: "skinImage2LEG", icon: "skinIcon2LEG", price: 100),
        LEGItem(name: "skin1", image: "skinImage1LEG", icon: "skinIcon1LEG", price: 100),
        LEGItem(name: "skin3", image: "skinImage3LEG", icon: "skinIcon3LEG", price: 100),
    ]
    
    // MARK: – Bought
    @Published var boughtBgItems: [LEGItem] = [
        LEGItem(name: "bg2", image: "bgImage2LEG", icon: "gameBgIcon2LEG", price: 100),
    ] {
        didSet { saveBoughtBg() }
    }

    @Published var boughtSkinItems: [LEGItem] = [
        LEGItem(name: "skin2", image: "skinImage2LEG", icon: "skinIcon2LEG", price: 100),
    ] {
        didSet { saveBoughtSkins() }
    }
    
    // MARK: – Current selections
    @Published var currentBgItem: LEGItem? {
        didSet { saveCurrentBg() }
    }
    @Published var currentSkinItem: LEGItem? {
        didSet { saveCurrentSkin() }
    }
    
    // MARK: – UserDefaults keys
    private let bgKey            = "currentBgLEG1"
    private let boughtBgKey      = "boughtBgLEG1"
    private let skinKey          = "currentSkinLEG2"
    private let boughtSkinKey    = "boughtSkinLEG2"
    
    // MARK: – Init
    init() {
        loadCurrentBg()
        loadBoughtBg()
                
        loadCurrentSkin()
        loadBoughtSkins()
    }
    
    // MARK: – Save / Load Backgrounds
    private func saveCurrentBg() {
        guard let item = currentBgItem,
              let data = try? JSONEncoder().encode(item)
        else { return }
        UserDefaults.standard.set(data, forKey: bgKey)
    }
    private func loadCurrentBg() {
        if let data = UserDefaults.standard.data(forKey: bgKey),
           let item = try? JSONDecoder().decode(LEGItem.self, from: data) {
            currentBgItem = item
        } else {
            currentBgItem = shopBgItems.first
        }
    }
    private func saveBoughtBg() {
        guard let data = try? JSONEncoder().encode(boughtBgItems) else { return }
        UserDefaults.standard.set(data, forKey: boughtBgKey)
    }
    private func loadBoughtBg() {
        if let data = UserDefaults.standard.data(forKey: boughtBgKey),
           let items = try? JSONDecoder().decode([LEGItem].self, from: data) {
            boughtBgItems = items
        }
    }
    
    // MARK: – Save / Load Skins
    private func saveCurrentSkin() {
        guard let item = currentSkinItem,
              let data = try? JSONEncoder().encode(item)
        else { return }
        UserDefaults.standard.set(data, forKey: skinKey)
    }
    private func loadCurrentSkin() {
        if let data = UserDefaults.standard.data(forKey: skinKey),
           let item = try? JSONDecoder().decode(LEGItem.self, from: data) {
            currentSkinItem = item
        } else {
            currentSkinItem = shopSkinItems.first
        }
    }
    private func saveBoughtSkins() {
        guard let data = try? JSONEncoder().encode(boughtSkinItems) else { return }
        UserDefaults.standard.set(data, forKey: boughtSkinKey)
    }
    private func loadBoughtSkins() {
        if let data = UserDefaults.standard.data(forKey: boughtSkinKey),
           let items = try? JSONDecoder().decode([LEGItem].self, from: data) {
            boughtSkinItems = items
        }
    }
    
    // MARK: – Example buy action
    func buy(_ item: LEGItem, category: LEGItemCategory) {
        switch category {
        case .background:
            guard !boughtBgItems.contains(item) else { return }
            boughtBgItems.append(item)
        case .skin:
            guard !boughtSkinItems.contains(item) else { return }
            boughtSkinItems.append(item)
        }
    }
    
    func isPurchased(_ item: LEGItem, category: LEGItemCategory) -> Bool {
        switch category {
        case .background:
            return boughtBgItems.contains(where: { $0.name == item.name })
        case .skin:
            return boughtSkinItems.contains(where: { $0.name == item.name })
        }
    }

    func selectOrBuy(_ item: LEGItem, user: LEGUser, category: LEGItemCategory) {
        
        switch category {
        case .background:
            if isPurchased(item, category: .background) {
                currentBgItem = item
            } else {
                guard user.money >= item.price else {
                    return
                }
                user.minusUserMoney(for: item.price)
                buy(item, category: .background)
            }
        case .skin:
            if isPurchased(item, category: .skin) {
                currentSkinItem = item
            } else {
                guard user.money >= item.price else {
                    return
                }
                user.minusUserMoney(for: item.price)
                buy(item, category: .skin)
            }
        }
    }
    
    func isMoneyEnough(item: LEGItem, user: LEGUser, category: LEGItemCategory) -> Bool {
        user.money >= item.price
    }
    
    func isCurrentItem(item: LEGItem, category: LEGItemCategory) -> Bool {
        switch category {
        case .background:
            guard let currentItem = currentBgItem, currentItem.name == item.name else {
                return false
            }
            
            return true
            
        case .skin:
            guard let currentItem = currentSkinItem, currentItem.name == item.name else {
                return false
            }
            
            return true
        }
    }
    
    func nextCategory(category: LEGItemCategory) -> LEGItemCategory {
        if category == .skin {
            return .background
        } else {
            return .skin
        }
    }
}

enum LEGItemCategory: String {
    case background = "background"
    case skin = "skin"
}

struct LEGItem: Codable, Hashable {
    var id = UUID()
    var name: String
    var image: String
    var icon: String
    var price: Int
    var rate: Double = 1.0
    var level: Int = 1
}
