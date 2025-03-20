import Foundation

class BlockchainNetwork {
    
    private var networkPeers = ["127.0.0.1:3000"]

    func shareBlock(block: Block) async -> Bool {
        var success = false

        for peer in networkPeers {
            let urlString = "http://\(peer)/receiveBlock"
            guard let url = URL(string: urlString) else {
                print("Invalid peer URL: \(peer)")
                continue
            }

            if await sendBlockToPeer(url: url, block: block) {
                success = true
            }
        }

        return success
    }

    private func sendBlockToPeer(url: URL, block: Block) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let blockData: [String: Any] = [
            "index": block.index,
            "timestamp": block.timestamp.timeIntervalSince1970,
            "previousHash": block.previousHash,
            "hash": block.hash,
            "nonce": block.nonce
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: blockData, options: [])
        } catch {
            print("Error encoding block data: \(error.localizedDescription)")
            return false
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                print("Failed to send block to \(url). Response: \(String(data: data, encoding: .utf8) ?? "No Data")")
                return false
            }
        } catch {
            print("Network error sending block to \(url): \(error.localizedDescription)")
            return false
        }
    }
}
