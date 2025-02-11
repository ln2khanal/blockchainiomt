//
//  ContentView.swift
//  Vitals Watch App
//
//  Created by Lekh Nath Khanal on 10/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var isRunning = false

    var body: some View {
        VStack {
            Image(systemName: "stethoscope")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Blockchain With IOMT")
            
            Button(action: startBackgroundTask) {
                Text(isRunning ? "Stop" : "Start")
            }
            .padding()
            .background(isRunning ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
    }
    
    private func startBackgroundTask() {
        if isRunning {
//            already in running state, stop button has been clicked
            isRunning = false
        }
        else {
            isRunning = true
        }
        print("Process state: \(isRunning)")
        // Background task logic will be implemented later
    }
}

#Preview {
    ContentView()
}
