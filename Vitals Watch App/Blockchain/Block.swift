import Foundation

// MARK: - Block Structure
class Block {
    var index: Int
    var timestamp: Date
    var transactions: [String] // Placeholder for actual transaction objects
    var previousHash: String
    var hash: String
    var nonce: Int

    init(index: Int, transactions: [String], previousHash: String) {
        self.index = index
        self.timestamp = Date()
        self.transactions = transactions
        self.previousHash = previousHash
        self.nonce = 0
        self.hash = "PLACEHOLDER_HASH_FUNCTION" // Placeholder for actual hash function
    }

    // Placeholder for a proper hashing function
    func computeHash() -> String {
        return "PLACEHOLDER_HASH_LOGIC"
    }
}

// MARK: - Blockchain Structure
class Blockchain {
    var chain: [Block]
    var pendingTransactions: [String] // Placeholder for actual transaction objects
    let difficulty: Int = 2 // Proof-of-work difficulty level

    init() {
        chain = []
//        create genesis block and append it to the chain
        pendingTransactions = []
    }

    private func createGenesisBlock() -> Block {
        return Block(index: 0, transactions: ["Genesis Block"], previousHash: "0")
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
        let block = Block(index: chain.count, transactions: pendingTransactions, previousHash: getLatestBlock().hash)
        proofOfWork(block: block)
        chain.append(block)
        pendingTransactions = ["Reward to \(minerAddress)"]
    }

    func proofOfWork(block: Block) {
        while !block.hash.hasPrefix(String(repeating: "0", count: difficulty)) {
            block.nonce += 1
            block.hash = block.computeHash()
        }
    }
}

// MARK: - Transactions (Placeholder for Smart Contracts)
class SmartContract {
    // Define smart contract logic here
    // This can be a function that validates and executes transactions based on predefined rules
    func execute() {
        print("PLACEHOLDER_SMART_CONTRACT_EXECUTION")
    }
}

// MARK: - Blockchain Network (Placeholder for Networking)
class BlockchainNetwork {
    // Define networking logic to synchronize blocks with peers
    func synchronize() {
        print("PLACEHOLDER_NETWORK_SYNC")
    }
}

// MARK: - Example Usage
class BlockchainApp {
    func run() {
        let blockchain = Blockchain()
        blockchain.pendingTransactions.append("Alice pays Bob 10 coins")
        blockchain.minePendingTransactions(minerAddress: "Miner1")

        for block in blockchain.chain {
            print("Block #\(block.index) -> Hash: \(block.hash)")
        }
    }
}
