//
//  NEGDeviceManager.swift
//  Lucky Eagle Gaming
//
//


import UIKit

class NEGDeviceManager {
    static let shared = NEGDeviceManager()
    
    var deviceType: UIUserInterfaceIdiom
    
    private init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom
    }
}
