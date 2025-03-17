//
//  DeviceSpecs.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 17/03/2025.
//

import Foundation
import KeychainAccess

func getPersistentDeviceID() -> String {
    let keychain = Keychain(service: "com.lekhnathkhanal.thesis.vitals.watchkitapp")
    
    if let existingID = keychain["deviceID"] {
        return existingID
    } else {
        let newID = UUID().uuidString
        keychain["deviceID"] = newID
        return newID
    }
}
