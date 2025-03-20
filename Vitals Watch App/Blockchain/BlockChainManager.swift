import Foundation

class BlockchainManager: ObservableObject {
    static let shared = BlockchainManager()

    @Published var blockchain: Blockchain
    private var processingTimer: Timer?
    
    private init() {
        blockchain = Blockchain()
        startPeriodicProcessing()
    }

    func startPeriodicProcessing() {
        processingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            print("Processing mempool data...\n\n")
            self.processMempoolData()
        }
    }

    func stopPeriodicProcessing() {
        processingTimer?.invalidate()
        processingTimer = nil
    }

    func addToMempool(bloodPressure: String, spo2: Double, bodyTemperature: Double, heartRate: Double, miner: String, patientIdentifier: String) {
        let transaction = Transaction(
            bloodPressure: bloodPressure,
            spo2: Int(spo2),
            bodyTemperature: bodyTemperature,
            heartRate: Int(heartRate),
            miner: miner,
            patientIdentifier: patientIdentifier
        )
        blockchain.addToMempool(transaction: transaction)
    }

    func processMempoolData() {
        print("Length of Chain: \(blockchain.chain.count)")
        blockchain.processMempoolData()
    }
}
