//
//  ContentView.swift
//  Vitals Watch App
//
//  Created by Lekh Nath Khanal on 10/02/2025.
//

import Combine
import HealthKit

class HeartRateStreamManager: ObservableObject {
    @Published var heartRate: Double = 0.0
    private var cancellables = Set<AnyCancellable>()
    private let healthStore = HKHealthStore()
    
    init() {
        // Example: Create a publisher that fetches heart rate data periodically
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchLatestHeartRate()
            }
            .store(in: &cancellables)
    }
    
    private func fetchLatestHeartRate() {
        // This is a simplified placeholder. In a real app, you would query HealthKit.
        // Assume you get a new heart rate value from HealthKit.
        let newHeartRate = Double.random(in: 60...100)
        DispatchQueue.main.async {
            self.heartRate = newHeartRate
//            print("Updated Heart Rate: \(newHeartRate)")
        }
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var streamManager = HeartRateStreamManager()
    
    var body: some View {
        VStack {
            Text("Current Heart Rate: \(streamManager.heartRate, specifier: "%.0f") BPM")
                .font(.headline)
        }
        .padding()
    }
}
