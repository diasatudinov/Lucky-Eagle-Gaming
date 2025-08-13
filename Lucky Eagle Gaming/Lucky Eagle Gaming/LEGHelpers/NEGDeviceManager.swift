//
//  NEGDeviceManager.swift
//  Lucky Eagle Gaming
//
//  Created by Dias Atudinov on 13.08.2025.
//


import UIKit

class NEGDeviceManager {
    static let shared = NEGDeviceManager()
    
    var deviceType: UIUserInterfaceIdiom
    
    private init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom
    }
}