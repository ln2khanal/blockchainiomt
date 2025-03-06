import Foundation
import CryptoKit


class Block {
    var index: Int
    var timestamp: Date
    var transactions: [String]
    var previousHash: String
    var hash: String
    var nonce: Int

    init(index: Int, transactions: [String], previousHash: String) {
        self.index = index
        self.timestamp = Date()
        self.transactions = transactions
        self.previousHash = previousHash
        self.nonce = 0
        self.hash = ""
        self.hash = computeHash()
    }

    func computeHash() -> String {
        let blockString = "\(index)\(timestamp.timeIntervalSince1970)\(transactions.joined())\(previousHash)\(nonce)"
        // Compute SHA256 hash of the block string.
        let hashData = SHA256.hash(data: Data(blockString.utf8))
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String]
    let difficulty: Int = 2

    init() {
        // Create genesis block and add it to the chain
        self.chain = [Block(index: 0, transactions: ["Genesis Block"], previousHash: "0")]
        self.pendingTransactions = []
    }

    func getLatestBlock() -> Block {
        return chain.last!
    }

    func addBlock(newBlock: Block) {
        newBlock.previousHash = getLatestBlock().hash
        newBlock.hash = newBlock.computeHash()
        chain.append(newBlock)
    }

    func minePendingTransactions(minerAddress: String) {
        // Create a new block with all pending transactions
        let block = Block(index: chain.count, transactions: pendingTransactions, previousHash: getLatestBlock().hash)
        proofOfWork(block: block)
        chain.append(block)
        // Reset pending transactions with a miner reward transaction.
        pendingTransactions = ["Reward to \(minerAddress)"]
    }

    func proofOfWork(block: Block) {
        let targetPrefix = String(repeating: "0", count: difficulty)
        while !block.hash.hasPrefix(targetPrefix) {
            block.nonce += 1
            block.hash = block.computeHash()
        }
    }
}


class SmartContract {
    func execute() {
        print("Executing smart contract logic")
    }
}
