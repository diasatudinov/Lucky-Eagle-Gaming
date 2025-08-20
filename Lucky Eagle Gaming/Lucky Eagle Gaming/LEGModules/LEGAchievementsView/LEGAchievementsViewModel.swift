//
//  NEGAchievementsViewModel.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

class LEGAchievementsViewModel: ObservableObject {
    
    @Published var achievements: [LEGAchievement] = [
        LEGAchievement(image: "achieve1ImageLEG",isAchieved: false),
        LEGAchievement(image: "achieve2ImageLEG",isAchieved: false),
        LEGAchievement(image: "achieve3ImageLEG",isAchieved: false),
        LEGAchievement(image: "achieve4ImageLEG",isAchieved: false),
        LEGAchievement(image: "achieve5ImageLEG",isAchieved: false),

    ] {
        didSet {
            saveAchievementsItem()
        }
    }
    
    init() {
        loadAchievementsItem()
        
    }
    
    private let userDefaultsAchievementsKey = "achievementsKeyNEG"
    
    func achieveToggle(_ achive: LEGAchievement) {
        guard let index = achievements.firstIndex(where: { $0.id == achive.id })
        else {
            return
        }
        achievements[index].isAchieved.toggle()
        
    }
    
    
    func saveAchievementsItem() {
        if let encodedData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsAchievementsKey)
        }
        
    }
    
    func loadAchievementsItem() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsAchievementsKey),
           let loadedItem = try? JSONDecoder().decode([LEGAchievement].self, from: savedData) {
            achievements = loadedItem
        } else {
            print("No saved data found")
        }
    }
}

struct LEGAchievement: Codable, Hashable, Identifiable {
    var id = UUID()
    var image: String
    var isAchieved: Bool
}
