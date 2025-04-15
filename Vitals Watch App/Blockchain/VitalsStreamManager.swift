//
//  VitalsManager.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 28/02/2025.
//

import SwiftUI
import Foundation
import Combine
import HealthKit

class VitalsStreamManager: ObservableObject {
    @Published var heartRate: Double = 0.0
    @Published var bodyTemperature: Double = 0.0
    @Published var bodyOxygenLevel: Double = 0.0
    @Published var bloodPressure: String = "0/0"
    
    @AppStorage("useRealData") private var useRealData: Bool = false
    
    private var healthStore = HKHealthStore()
    
    private var cancellables = Set<AnyCancellable>()
    private var cpuMemoryTimer: Timer?
    
    init() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.startStreamingVitals()
            }
            .store(in: &cancellables)
        
        print("Device ID:\(getPersistentDeviceID())")
    }
    
    func startStreamingVitals() {
            if useRealData {
                updateLatestVitalsReal()
            } else {
                updateLatestVitalsRandom()
            }
        }
    
    private func updateLatestVitalsReal() {
            fetchHeartRate()
            fetchBodyTemperature()
            fetchOxygenLevel()
        }

    /// Fetch latest heart rate
    private func fetchHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                print("Heart Rate fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self.heartRate = bpm
            }
        }
        healthStore.execute(query)
    }
    
    /// Fetch latest body temperature
    private func fetchBodyTemperature() {
        let tempType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
        let query = HKSampleQuery(sampleType: tempType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                print("Body Temperature fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let temp = sample.quantity.doubleValue(for: HKUnit.degreeFahrenheit())
            DispatchQueue.main.async {
                self.bodyTemperature = temp
            }
        }
        healthStore.execute(query)
    }

    /// Fetch latest blood oxygen level
    private func fetchOxygenLevel() {
        let oxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let query = HKSampleQuery(sampleType: oxygenType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            guard let sample = results?.first as? HKQuantitySample else {
                print("Oxygen Level fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let spo2 = sample.quantity.doubleValue(for: HKUnit.percent()) * 100
            DispatchQueue.main.async {
                self.bodyOxygenLevel = spo2
            }
        }
        healthStore.execute(query)
    }
    
    private func updateLatestVitalsRandom() {
        let newHeartRate = Double.random(in: 60...100)
        let newBodyTemperature = Double.random(in: 97...106)
        let newBloodPressure = String(format: "%.0f", Double.random(in: 60...130)) + "/" + String(format: "%.0f", Double.random(in: 100...400))
        let newBodyOxygenLevel = Double.random(in: 80...100)
        
        DispatchQueue.main.async {
            self.heartRate = newHeartRate
            self.bodyTemperature = newBodyTemperature
            self.bloodPressure = newBloodPressure
            self.bodyOxygenLevel = newBodyOxygenLevel
        }
        processVitalsData()
    }
    
    func processVitalsData(){
        let patientID: String = getPersistentDeviceID()
        
        BlockchainManager.shared.addToMempool(
            bloodPressure: self.bloodPressure,
            spo2: self.bodyOxygenLevel,
            bodyTemperature: self.bodyTemperature,
            heartRate: self.heartRate,
            miner: "IOMT-Watch(\(patientID))",
            patientIdentifier: patientID
        )

//        Task {
//            await BlockchainNetwork(peers: peers).shareBlock(block: addedBlock)
//        }
        
//        NotificationManager.shared.scheduleNotification(addedBlock: addedBlock)
    }

}
