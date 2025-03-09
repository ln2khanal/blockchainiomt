//
//  Vitals.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 08/03/2025.
//

//import Foundation
//import HealthKit
//
//func requestHealthKitAuthorization() {
//    
//    let healthStore = HKHealthStore()
//        
//    guard HKHealthStore.isHealthDataAvailable() else { return }
//        
//    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//    let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
//    let bodyOxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
//
//    let typesToRead: Set<HKObjectType> = [heartRateType, bodyTemperatureType, bodyOxygenType]
//
//    healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
//        if success {
//            print("HealthKit Authorization Granted!")
//        } else {
//            print("HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
//        }
//    }
//}
