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
    private var cpuMemoryTimer: Timer?
    
    init() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLatestVitals()
            }
            .store(in: &cancellables)
        
        print("File Path:\(getUsageFilePath().absoluteString)\n")
        
        cpuMemoryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            appendRecordToJsonFile(memoryInfo: getMemoryUsage(), cpuUsage: getCPUUsage())
        }
    }
    
    private func updateLatestVitals() {
        let newHeartRate = Double.random(in: 60...100)
        let newBodyTemperature = Double.random(in: 97...106)
        let newBloodPressure = String(format: "%.0f", Double.random(in: 60...130)) + "/" + String(format: "%.0f", Double.random(in: 100...400))
        let newBodyOxygenLevel = Double.random(in: 80...100)
         
        let peers = ["127.0.0.1:3000"]
        
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
            heartRate: self.heartRate,
            miner: "IOMT-Watch"
        )

        Task {
            await BlockchainNetwork(peers: peers).shareBlock(block: addedBlock)
        }
        
        NotificationManager.shared.scheduleNotification(addedBlock: addedBlock)
    }

}
