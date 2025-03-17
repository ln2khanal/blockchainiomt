//
//  BlockChainManager.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 24/02/2025.
//

import Foundation

class BlockchainManager: ObservableObject {
    static let shared = BlockchainManager()
    
    struct Vitals: Codable {
        let bloodPressure: String
        let spo2: Int
        let bodyTemperature: Double
        let heartRate: Int
        let patientIdentifier: String
        func toDictionary() -> [String: Any] {
                return [
                    "bloodPressure": bloodPressure,
                    "spo2": spo2,
                    "bodyTemperature": bodyTemperature,
                    "heartRate": heartRate,
                    "patientIdentifier": patientIdentifier
                ]
            }
    }

    private var blockchain: Blockchain

    private init() {
        blockchain = Blockchain()
    }

    /// Appends vitals data as a new transaction and mines a new block.
    func submitVitalsData(bloodPressure: String, spo2: Double, bodyTemperature: Double, heartRate: Double, miner: String, patiendIdentifier: String) -> Block {
        
        let vitalsData = try? JSONSerialization.data(withJSONObject: Vitals(
            bloodPressure: bloodPressure,
            spo2: Int(spo2),
            bodyTemperature: bodyTemperature,
            heartRate: Int(heartRate),
            patientIdentifier: patiendIdentifier
        ).toDictionary(), options: .prettyPrinted)
        
        blockchain.data = String(data: vitalsData!, encoding: .utf8)!
        blockchain.pendingTransactions.append("Vital Record for patient:\(patiendIdentifier)")
        blockchain.minePendingTransactions(minerAddress: miner)
        
        let addedBlock = blockchain.chain.last!
        
//        print("\nNew block added with data:\n---\n\(vitalsData)\nHash: \(addedBlock.hash)\n---Total Blocks: \(blockchain.chain.count)\n")
        
        return addedBlock
    }
}
