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
    @AppStorage("blockchainStorageScheme") private var blockchainStorageScheme: String = "Memory"

    let hasingAlgorighms: [Int] = [256, 512]
    let storageSchemes: [String] = ["Memory", "Local", "External"]

    var body: some View {
        Form {
            Toggle("Use Real Sensor Data", isOn: $useRealData)

            Picker("Hashing Algorithm", selection: $hashingAlgorithm) {
                ForEach(hasingAlgorighms, id: \.self) { algo in
                    Text("SHA-\(algo)").tag(algo)
                }
            }
            Picker("Block Storage Scheme", selection: $blockchainStorageScheme) {
                ForEach(storageSchemes, id: \.self) { scheme in
                    Text(scheme).tag(scheme)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
