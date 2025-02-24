import Foundation
import CryptoKit


class Block {
    var index: Int
    var timestamp: Date
    var transactions: [String] // Here we store transaction strings
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

    /// Computes the hash using SHA256 over the block’s contents.
    func computeHash() -> String {
        // Create a string that includes all block properties.
        let blockString = "\(index)\(timestamp.timeIntervalSince1970)\(transactions.joined())\(previousHash)\(nonce)"
        // Compute SHA256 hash of the block string.
        let hashData = SHA256.hash(data: Data(blockString.utf8))
        // Convert hash data to a hex string.
        return hashData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Blockchain
class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String] // Stores transaction data strings
    let difficulty: Int = 2 // Proof-of-work difficulty level

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

    /// Performs proof-of-work by adjusting the nonce until the hash starts with the required prefix.
    func proofOfWork(block: Block) {
        let targetPrefix = String(repeating: "0", count: difficulty)
        while !block.hash.hasPrefix(targetPrefix) {
            block.nonce += 1
            block.hash = block.computeHash()
        }
    }
}

// MARK: - SmartContract (Placeholder Implementation)
class SmartContract {
    func execute() {
        print("Executing smart contract logic")
    }
}

// MARK: - Blockchain Network (Placeholder Implementation)
class BlockchainNetwork {
    func synchronize() {
        print("Synchronizing blockchain network")
    }
}
//
//// MARK: - Blockchain Application
//class BlockchainApp {
//    func run() {
//        print("Initiating blockchain")
//        let blockchain = Blockchain()
//
//        // Insert the vitals data as a transaction:
//        let vitalsData = """
//        Blood Pressure: 90/120,
//        SPO3: 98%,
//        Body Temperature: 99 F,
//        Heart Rate: 72
//        """
//        blockchain.pendingTransactions.append(vitalsData)
//
//        // Optionally, add any other transactions here.
//        blockchain.minePendingTransactions(minerAddress: "Miner1")
//
//        print("Iterating through blockchain:")
//        for block in blockchain.chain {
//            print("Block #\(block.index)")
//            print("Timestamp: \(block.timestamp)")
//            print("Transactions: \(block.transactions)")
//            print("Previous Hash: \(block.previousHash)")
//            print("Hash: \(block.hash)")
//            print("Nonce: \(block.nonce)")
//            print("--------------")
//        }
//    }
//}
