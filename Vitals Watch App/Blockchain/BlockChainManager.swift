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
    func submitVitalsData(bloodPressure: String, spo2: Double, bodyTemperature: Double, heartRate: Double, miner: String) -> Block {
        let vitalsData = """
        Blood Pressure: \(bloodPressure),
        SpO2: \(spo2)%,
        Body Temperature: \(bodyTemperature) °F,
        Heart Rate: \(heartRate)
        """
        blockchain.pendingTransactions.append(vitalsData)
        blockchain.minePendingTransactions(minerAddress: miner)
        
        let addedBlock = blockchain.chain.last!
        
//        print("\nNew block added with data:\n---\n\(vitalsData)\nHash: \(addedBlock.hash)\n---Total Blocks: \(blockchain.chain.count)\n")
        
        return addedBlock
    }
}
