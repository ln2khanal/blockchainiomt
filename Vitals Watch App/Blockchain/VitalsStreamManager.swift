//
//  VitalsManager.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 28/02/2025.
//

import Foundation
import Combine
import HealthKit

class VitalsStreamManager: ObservableObject {
    @Published var heartRate: Double = 0.0
    @Published var bodyTemperature: Double = 0.0
    @Published var bodyOxygenLevel: Double = 0.0
    @Published var bloodPressure: String = "0/0"
    
    private var cancellables = Set<AnyCancellable>()
    private let healthStore = HKHealthStore()
    
    init() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchLatestVitals()
            }
            .store(in: &cancellables)
    }
    
    private func fetchLatestVitals() {
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
        
        let addedBlock = BlockchainManager.shared.submitVitalsData(
            bloodPressure: self.bloodPressure,
            spo2: self.bodyOxygenLevel,
            bodyTemperature: self.bodyTemperature,
            heartRate: self.heartRate
        )

        Task {
            await BlockchainNetwork(peers: ["127.0.0.1:3000"]).shareBlock(block: addedBlock)
        }
        
        NotificationManager.shared.scheduleNotification(addedBlock: addedBlock)
    }

}
