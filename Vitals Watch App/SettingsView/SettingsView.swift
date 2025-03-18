//
//  SettingsView.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 08/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useRealData") private var useRealData: Bool = false
    @AppStorage("hashingAlgorithm") private var hashingAlgorithm: Int = 256

    let hasingAlgorighms = [256, 512]

    var body: some View {
        Form {
            Toggle("Use Real Sensor Data", isOn: $useRealData)

            Picker("Hashing Algorithm", selection: $hashingAlgorithm) {
                ForEach(hasingAlgorighms, id: \.self) { algo in
                    Text("SHA-\(algo)").tag(algo)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
