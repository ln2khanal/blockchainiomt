//
//  BlockChainManager.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 24/02/2025.
//

import Foundation

class BlockchainManager: ObservableObject {
    static let shared = BlockchainManager()
    private var blockchain: Blockchain

    private init() {
        blockchain = Blockchain()
    }

    /// Appends vitals data as a new transaction and mines a new block.
    func submitVitalsData(bloodPressure: String, spo2: Int, bodyTemperature: Int, heartRate: Int, miner: String = "Miner1") {
        let vitalsData = """
        Blood Pressure: \(bloodPressure),
        SpO2: \(spo2)%,
        Body Temperature: \(bodyTemperature) F,
        Heart Rate: \(heartRate)
        """
        blockchain.pendingTransactions.append(vitalsData)
        blockchain.minePendingTransactions(minerAddress: miner)
        print("New block added with data:")
        for block in blockchain.chain {
            print("Block #\(block.index) -> Hash: \(block.hash)")
        }
    }
}
