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
}

class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String]
    var mempool: [Transaction]

    init() {
        self.chain = [Block(index: 0, transactions: ["Genesis Block"], previousHash: "0")]
        self.pendingTransactions = []
        self.mempool = [] // Initialize the mempool
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

    func processMempoolData() {
        if !mempool.isEmpty {
            let mempoolCopy = mempool
            mempool.removeAll()
            
            let transactions = mempoolCopy.map { $0.toString() } + [SmartContract.evaluate(mempoolCopy)]
            let block = Block(index: chain.count, transactions: transactions, previousHash: getLatestBlock().hash)
            
            ProofOfWork().validate(block: block)
            
            chain.append(block)
            
            Task {
                await BlockchainNetwork().shareBlock(block: block)
//                if fails, restore the transactions
            }
            
            
        } else {
            print("No transactions in the mempool to process.")
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
