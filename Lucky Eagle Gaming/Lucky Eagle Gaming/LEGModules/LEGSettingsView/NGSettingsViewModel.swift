//
//  NGSettingsViewModel.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

class NGSettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("brigthnessEnabled") var brigthnessEnabled: Bool = true

}
