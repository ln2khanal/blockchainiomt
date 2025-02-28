//
//  ContentView.swift
//  Vitals Watch App
//
//  Created by Lekh Nath Khanal on 10/02/2025.
//

import SwiftUI


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
            
//            Button("Push to Blockchain") {
//                streamManager.sendDataToBlockchain()
//            }
//            .font(.caption)
//            .padding(.vertical, -4)
//            .padding(.horizontal, 8)
//            .background(Color.red)
//            .foregroundColor(.white)
//            .clipShape(Capsule())
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
}
