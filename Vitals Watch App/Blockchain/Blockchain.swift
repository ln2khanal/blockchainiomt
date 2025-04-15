import Foundation
import SwiftUI
import CryptoKit

func hashData(_ data: String, algorithm: Int) -> String {
    let inputData = Data(data.utf8)
    
    if algorithm == 256 {
        let hash = SHA256.hash(data: inputData)
        return hash.map { String(format: "%02x", $0) }.joined()
    } else if algorithm == 512 {
        let hash = SHA512.hash(data: inputData)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    fatalError("Unsupported hashing algorithm: \(algorithm)")
}

class MerkleTree {
    var transactions: [String]
    var root: String?

    init(transactions: [String]) {
        self.transactions = transactions
        self.root = nil
    }

    func getMerkleTree() -> [[String]] {
        var tree: [[String]] = []
        var currentLevel = transactions.map { hash($0) }

        tree.append(currentLevel)

        while currentLevel.count > 1 {
            var nextLevel: [String] = []
            for i in stride(from: 0, to: currentLevel.count, by: 2) {
                if i + 1 < currentLevel.count {
                    nextLevel.append(hash(currentLevel[i] + currentLevel[i + 1]))
                } else {
                    nextLevel.append(currentLevel[i])
                }
            }

            currentLevel = nextLevel
            tree.append(currentLevel)
        }

        if let rootHash = currentLevel.first {
            self.root = rootHash
        }

        return tree
    }

    private func hash(_ data: String) -> String {
        let inputData = Data(data.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String]
    var mempool: [Transaction]
    var pendingBlocks: [String: (block: Block, approvals: Int, rejections: Int)] = [:]
    static let requiredThreshold: Int = 1
    
    init() {
        self.chain = [Block(index: 0, transactions: ["Genesis Block"], previousHash: "0")]
        self.pendingTransactions = []
        self.mempool = [] // Initialize the mempool
        PeerClient.shared.onValidationResponse = { [weak self] blockHash, isValid in
                self?.handlePeerValidationResponse(for: blockHash, isValid: isValid)
            }
    }

    func getLatestBlock() -> Block {
        return chain.last!
    }

    func addBlock(newBlock: Block) {
        newBlock.previousHash = getLatestBlock().hash
        chain.append(newBlock)
    }

    func addToMempool(transaction: Transaction) {
        mempool.append(transaction)
    }
    
    func handlePeerValidationResponse(for blockHash: String, isValid: Bool) {
        guard var record = pendingBlocks[blockHash] else { return }

        if isValid {
            record.approvals += 1
        } else {
            record.rejections += 1
        }

        pendingBlocks[blockHash] = record

        if record.approvals >= Blockchain.requiredThreshold {
            chain.append(record.block)
            pendingBlocks.removeValue(forKey: blockHash)
            print("Block added to chain.")
            PeerClient.shared.send(message: record.block.toDict(), action: "syncBlockchain")
        } else if record.rejections >= Blockchain.requiredThreshold {
            pendingBlocks.removeValue(forKey: blockHash)
            print("Block rejected by peers.")
        }
    }

    func processMempoolData() {
        if !mempool.isEmpty {
            let mempoolCopy = mempool
            mempool.removeAll()
            
            let transactions = mempoolCopy.map { $0.toString() } + [SmartContract.evaluate(mempoolCopy)]
            let block = Block(index: chain.count, transactions: transactions, previousHash: getLatestBlock().hash)
            
            ProofOfWork().validate(block: block)
            Task {
                pendingBlocks[block.hash] = (block, 0, 0)
                print("Broadcasting block\(block.hash) to network for validation...\n")
                PeerClient.shared.send(message: block.toDict(), action: "validateBlock")
            }
        }
    }
    
}

class Transaction {
    let bloodPressure: String
    let spo2: Int
    let bodyTemperature: Double
    let heartRate: Int
    let miner: String
    let patientIdentifier: String

    init(bloodPressure: String, spo2: Int, bodyTemperature: Double, heartRate: Int, miner: String, patientIdentifier: String) {
        self.bloodPressure = bloodPressure
        self.spo2 = spo2
        self.bodyTemperature = bodyTemperature
        self.heartRate = heartRate
        self.miner = miner
        self.patientIdentifier = patientIdentifier
    }

    func toString() -> String {
        return "bloodPressure:\(bloodPressure)-spo2:\(spo2) -bodyTemperature:\(bodyTemperature)-heartRate:\(heartRate)-miner:\(miner)-patientIdentifier:\(patientIdentifier)"
    }
}
