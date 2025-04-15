import Foundation
import Network

class PeerClient {
    static let shared = PeerClient()
    private var connection: NWConnection!
    private var buffer = Data()
    
    var onValidationResponse: ((String, Bool) -> Void)? = nil
    
    private init() {
        connection = NWConnection(host: "127.0.0.1", port: 9000, using: .tcp)
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("Connected to server!")
                self?.startListening()
            case .failed(let error):
                print("Connection failed: \(error)")
            default:
                break
            }
        }
        
        connection.start(queue: .main)
        startListening()
    }

    func send(message: String, action: String) {
        let payload: [String: Any] = [
            "message": message,
            "action": action,
            "deviceID": getPersistentDeviceID()
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("Failed to serialize payload.")
            return
        }

        var fullData = data
        fullData.append(0x0A)
        
        connection.send(content: fullData, completion: .contentProcessed({ error in
            if let error = error {
                print("Error sending: \(error)")
            } else {
                print("Message sent for action: \(action)")
            }
        }))
    }

    func receivePeerMessage(message: String) -> Void {
        guard let jsonData = message.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              let action = jsonObject["action"] as? String else {
            print("Invalid or missing JSON/action")
            return
        }
        guard let payload = jsonObject["message"] as? String else {
            print("Message payload missing")
            return
        }

        switch action {
        case "validateBlock":
            let valid = validatePeerBlock(blockString: payload)

            if let blockData = payload.data(using: .utf8),
               let blockJson = try? JSONSerialization.jsonObject(with: blockData) as? [String: Any],
               let blockHash = blockJson["hash"] as? String {
                let responsePayload: [String: Any] = [
                    "action": "validationResponse",
                    "message": "block validated",
                    "blockHash": blockHash,
                    "isValid": valid,
                    "deviceID": getPersistentDeviceID(),
                    "clientDeviceID": blockJson["deviceID"] ?? "N/A"
                ]
                if let responseData = try? JSONSerialization.data(withJSONObject: responsePayload) {
                    var fullResponse = responseData
                    fullResponse.append(0x0A)
                    print("Payload: \(blockJson)\nResponse: \(String(data: fullResponse, encoding: .utf8) ?? "Unprintable"))")
                    connection.send(content: fullResponse, completion: .contentProcessed { _ in })
                }
            }

        case "validationResponse":
            guard let blockHash = jsonObject["blockHash"] as? String,
                  let isValid = jsonObject["isValid"] as? Bool else {
                return
            }
            onValidationResponse?(blockHash, isValid)

        case "syncBlockchain":
            print("Sync request received.")

        default:
            print("Unrecognized action: \(action)")
        }
    }

    private func startListening() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, _, error in
            guard let self = self else { return }

            if let error = error {
                print("Receive error: \(error)")
            }

            if let data = data {
                self.buffer.append(data)

                while let newlineRange = self.buffer.range(of: Data([0x0A])) { // Newline delimiter
                    let lineData = self.buffer.subdata(in: 0..<newlineRange.lowerBound)
                    self.buffer.removeSubrange(0...newlineRange.lowerBound)

                    if let message = String(data: lineData, encoding: .utf8) {
                        self.receivePeerMessage(message: message)
                    }
                }
            }

            self.startListening()
        }
    }
}
