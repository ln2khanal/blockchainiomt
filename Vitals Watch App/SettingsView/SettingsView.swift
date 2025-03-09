//
//  SettingsView.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 08/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useRealData") private var useRealData: Bool = false
    
    var body: some View {
        Form {
            Toggle("Use Real Sensor Data", isOn: $useRealData)
        }
        .navigationTitle("Settings")
    }
}
