//
//  ContentView.swift
//  Vitals Watch App
//
//  Created by Lekh Nath Khanal on 10/02/2025.
//

import Combine
import HealthKit
import SwiftUI
import UserNotifications


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
    }
    func sendDataToBlockchain() {
            BlockchainManager.shared.submitVitalsData(
                bloodPressure: bloodPressure,
                spo2: Int(bodyOxygenLevel),
                bodyTemperature: Int(bodyTemperature),
                heartRate: Int(heartRate)
            )
        }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Blockchain Update"
        content.body = "Vitals pushed to the blockchain."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

}

struct ContentView: View {
    @StateObject private var streamManager = VitalsStreamManager()
    let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("HR(BPM)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(streamManager.heartRate, specifier: "%.0f")")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("BT(°F)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(streamManager.bodyTemperature, specifier: "%.0f")")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("BP(mmHg)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(streamManager.bloodPressure)
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("SpO2(%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(streamManager.bodyOxygenLevel, specifier: "%.0f")")
                            .font(.headline)
                    }
                }
                .padding()
            }
            
            Button("Push to Blockchain") {
                streamManager.sendDataToBlockchain()
            }
            .font(.caption)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
}
