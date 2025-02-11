import Foundation

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance
    
    func fetchData(completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else {
            completion("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
                return
            }
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(jsonString)
                }
            }
        }
        
        task.resume()
    }
}
