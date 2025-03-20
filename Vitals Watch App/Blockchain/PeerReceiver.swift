import Foundation
import Network
import Combine

class PeerReceiverServer {
    private var listener: NWListener?
    private var blockchainManager: BlockchainManager
    private var cancellables = Set<AnyCancellable>()

    init(blockchainManager: BlockchainManager = BlockchainManager.shared) {
        self.blockchainManager = blockchainManager
        blockchainManager.$blockchain
            .sink { [weak self] blockchain in
                self?.handleBlockchainUpdate(blockchain)
            }
            .store(in: &cancellables)
    }

    func startServer() {
        let parameters = NWParameters(tls: nil)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true

        let port: NWEndpoint.Port = 3001

        guard let listener = try? NWListener(using: parameters, on: port) else {
            print("Failed to create listener")
            return
        }

        self.listener = listener

        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Server is ready and listening on port \(port)")
            case .failed(let error):
                print("Server failed with error: \(error)")
            default:
                break
            }
        }

        listener.newConnectionHandler = { connection in
            self.handleConnection(connection)
        }

        listener.start(queue: .global())
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global())

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let request = String(data: data, encoding: .utf8) ?? ""
                print("Received request: \(request)")

                let response = self.processRequest(request)

                connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ error in
                    if let error = error {
                        print("Failed to send response: \(error)")
                    }
                    connection.cancel()
                }))
            }

            if isComplete || error != nil {
                connection.cancel()
            }
        }
    }

    private func processRequest(_ request: String) -> String {

        if request.contains("GET /merkle-tree") {
            return generateMerkleTreeResponse()
        }

        let responseBody = "Hello from watchOS!"
        return """
        HTTP/1.1 200 OK
        Content-Type: text/plain
        Content-Length: \(responseBody.count)

        \(responseBody)
        """
    }

    private func generateMerkleTreeResponse() -> String {
        let allTransactions = blockchainManager.blockchain.chain.flatMap { block in
            block.transactions.map { transaction in
                if let jsonData = try? JSONEncoder().encode(transaction),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
                return ""
            }
        }.filter { !$0.isEmpty }

        guard !allTransactions.isEmpty else {
            return "HTTP/1.1 500 Internal Server Error\n\nNo transactions in blockchain"
        }

        let merkleTree = MerkleTree(transactions: allTransactions)

        do {
            let jsonData = try JSONEncoder().encode(merkleTree.getMerkleTree())
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            return """
            HTTP/1.1 200 OK
            Content-Type: application/json
            Content-Length: \(jsonString.count)

            \(jsonString)
            """
        } catch {
            return "HTTP/1.1 500 Internal Server Error\n\nFailed to generate Merkle Tree"
        }
    }

    private func handleBlockchainUpdate(_ blockchain: Blockchain) {
        print("Blockchain updated, new block count: \(blockchain.chain.count)")
    }

}
