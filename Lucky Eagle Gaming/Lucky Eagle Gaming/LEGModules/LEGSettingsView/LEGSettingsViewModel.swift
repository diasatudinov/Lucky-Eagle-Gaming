//
//  LEGSettingsViewModel.swift
//  Lucky Eagle Gaming
//
//


import SwiftUI

class LEGSettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("brigthnessEnabled") var brigthnessEnabled: Bool = true

}
