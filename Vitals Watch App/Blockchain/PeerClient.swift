import Foundation
import Network

class PeerClient {
    static let shared = PeerClient()
    private var connection: NWConnection!
    private var responseCallback: ((String?) -> Void)?

    private init() {
        connection = NWConnection(host: "127.0.0.1", port: 9000, using: .tcp)

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("✅ Connected to server!")
                self?.startListening()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    func send(message: String, action: String, completion: @escaping (String?) -> Void) {
        let payload: [String: Any] = [
            "message": message,
            "action": action
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("❌ Failed to serialize payload.")
            completion(nil)
            return
        }

        responseCallback = completion

        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("❌ Error sending: \(error)")
                completion(nil)
            } else {
                print("✅ Sent message: \(message)")
            }
        }))
    }

    private func startListening() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, _, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Receive error: \(error)")
            }

            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("Incoming message: \(message)")

                if let callback = self.responseCallback {
                    callback(message)
                    self.responseCallback = nil
                } else {
                    print("message received: \(message)")
                }
            }
            self.startListening()
        }
    }
}
