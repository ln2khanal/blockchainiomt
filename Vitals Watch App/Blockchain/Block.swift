//
//  Block.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 31/03/2025.
//

import Foundation
import SwiftUI


class Block {
    var index: Int
    var timestamp: Date
    var previousHash: String
    var nonce: Int
    var transactions: [String]
    var merkleRoot: String
    
    var hash: String {
        computeHash()
    }
    
    @AppStorage("hashingAlgorithm") private var hashingAlgorithm: Int = 256
    
    init(index: Int, transactions: [String], previousHash: String) {
        self.index = index
        self.timestamp = Date()
        self.previousHash = previousHash
        self.nonce = 0
        self.transactions = transactions
        
        let merkleTree = MerkleTree(transactions: transactions)
        self.merkleRoot = merkleTree.root ?? ""
    }

    func computeHash() -> String {
        let blockString = "\(index)\(timestamp.timeIntervalSince1970)\(previousHash)\(nonce)\(transactions.joined())\(merkleRoot)"
        return hashData(blockString, algorithm: hashingAlgorithm)
    }
    
    func toDict() -> String {
            let blockDict: [String: Any] = [
                "index": index,
                "timestamp": timestamp.timeIntervalSince1970,
                "previousHash": previousHash,
                "nonce": nonce,
                "transactions": transactions,
                "merkleRoot": merkleRoot,
                "hash": hash
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: blockDict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            
            return "{}"
        }
    
    func estimatedSizeInBytes() -> Int {
            let indexSize = MemoryLayout.size(ofValue: index) // 8 bytes
            let timestampSize = MemoryLayout.size(ofValue: timestamp) // 8 bytes
            let nonceSize = MemoryLayout.size(ofValue: nonce) // 8 bytes
            let hashingAlgoSize = MemoryLayout.size(ofValue: hashingAlgorithm) // 8 bytes (if counted)

            let previousHashSize = previousHash.utf8.count
            let merkleRootSize = merkleRoot.utf8.count
            
            // Total transaction strings size
            let transactionsSize = transactions.reduce(0) { $0 + $1.utf8.count }

            // Array overhead (pointer + capacity)
            let transactionArrayOverhead = transactions.count * MemoryLayout<String>.stride

            // Total estimated size
            let total = indexSize
                      + timestampSize
                      + nonceSize
                      + hashingAlgoSize
                      + previousHashSize
                      + merkleRootSize
                      + transactionsSize
                      + transactionArrayOverhead

            return total
        }
}
