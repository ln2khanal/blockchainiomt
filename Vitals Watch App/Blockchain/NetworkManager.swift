import Foundation

class BlockchainNetwork {
    var peers: [String]

    init(peers: [String] = []) {
        self.peers = peers
    }


    func shareBlock(block: Block) async {
        print("Sharing block with index \(block.index) to peers...")

        for peer in peers {
            let urlString = "http://\(peer)/receiveBlock"
            if let url = URL(string: urlString) {
                sendBlockToPeer(url: url, block: block)
            } else {
                print("Invalid peer URL: \(peer)")
            }
        }
    }

    private func sendBlockToPeer(url: URL, block: Block) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let blockData: [String: Any] = [
            "index": block.index,
            "timestamp": block.timestamp.timeIntervalSince1970,
            "transactions": block.transactions,
            "previousHash": block.previousHash,
            "hash": block.hash,
            "nonce": block.nonce
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: blockData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding block data: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending block to \(url): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Block sent to \(url), Response status: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}
