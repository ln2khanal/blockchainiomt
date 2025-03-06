
import Network

class PeerReceiverServer {
    private var listener: NWListener?

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
        // Parse the HTTP request and generate a response
        let responseBody = "Hello from watchOS!"
        return """
        HTTP/1.1 200 OK
        Content-Type: text/plain
        Content-Length: \(responseBody.count)

        \(responseBody)
        """
    }
}
