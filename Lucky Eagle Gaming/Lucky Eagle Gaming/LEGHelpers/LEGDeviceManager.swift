//
//  LEGDeviceManager.swift
//  Lucky Eagle Gaming
//
//


import UIKit

class LEGDeviceManager {
    static let shared = LEGDeviceManager()
    
    var deviceType: UIUserInterfaceIdiom
    
    private init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom
    }
}
