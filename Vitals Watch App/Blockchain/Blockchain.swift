import Foundation
import SwiftUI
import CryptoKit


class Block {
    var index: Int
    var timestamp: Date
    var transactions: [String]
    var previousHash: String
    var nonce: Int
    var data: String
    
    var hash: String{
        computeHash()
    }
    
    @AppStorage("hashingAlgorithm") private var hashingAlgorithm: Int = 256
    
    init(index: Int, transactions: [String], previousHash: String, data: String) {
        self.index = index
        self.timestamp = Date()
        self.transactions = transactions
        self.previousHash = previousHash
        self.nonce = 0
        self.data = data
    }

    func computeHash() -> String {
        let blockString = "\(index)\(timestamp.timeIntervalSince1970)\(transactions.joined())\(previousHash)\(nonce)\(data)"
        if hashingAlgorithm == 256 {
            let hashData = SHA256.hash(data: Data(blockString.utf8))
            return hashData.map { String(format: "%02x", $0) }.joined()
        }
        else if hashingAlgorithm == 512 {
            let hashData = SHA512.hash(data: Data(blockString.utf8))
            return hashData.map { String(format: "%02x", $0) }.joined()
        }
        
        fatalError("Hashing algorithm \(hashingAlgorithm) not implemented")
        
    }
}

class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String]
    let difficulty: Int = 2
    var data: String = ""

    init() {
        self.chain = [Block(index: 0, transactions: ["Genesis Block"], previousHash: "0", data: data)]
        self.pendingTransactions = []
    }

    func getLatestBlock() -> Block {
        return chain.last!
    }

    func addBlock(newBlock: Block) {
        newBlock.previousHash = getLatestBlock().hash
        
        chain.append(newBlock)
    }

    func minePendingTransactions(minerAddress: String) {
        // Create a new block with all pending transactions
        let block = Block(index: chain.count, transactions: pendingTransactions, previousHash: getLatestBlock().hash, data: data)
        proofOfWork(block: block)
        chain.append(block)
        // Reset pending transactions with a miner reward transaction.
        pendingTransactions = ["Reward to \(minerAddress)"]
    }

    func proofOfWork(block: Block) {
        let targetPrefix = String(repeating: "0", count: difficulty)
        while !block.hash.hasPrefix(targetPrefix) {
            block.nonce += 1
        }
    }
}


class SmartContract {
    func execute() {
        print("Executing smart contract logic")
    }
}
