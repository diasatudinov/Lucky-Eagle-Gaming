//
//  NGSettingsViewModel.swift
//  Lucky Eagle Gaming
//
//  Created by Dias Atudinov on 13.08.2025.
//


import SwiftUI

class NGSettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("brigthnessEnabled") var brigthnessEnabled: Bool = true

}
