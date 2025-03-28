struct SmartContract {
    static func evaluate(_ txs: [Transaction]) -> String {
        var alerts: [String] = []
        for tx in txs {
            if tx.heartRate > 120 {
                alerts.append("High heart rate: \(tx.heartRate)")
            }
            if tx.bodyTemperature > 38.0 {
                alerts.append("High temperature: \(tx.bodyTemperature)")
            }
            if tx.spo2 < 92 {
                alerts.append("Low blood oxygen: \(tx.spo2)")
            }
        }
        let stringAlerts = alerts.joined(separator: "\n")
        
        return stringAlerts
    }
}
