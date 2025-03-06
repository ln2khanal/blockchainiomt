//
//  JsonUpdater.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 04/03/2025.
//

import Foundation

func getUsageFilePath() -> URL {
    let fileManager = FileManager.default

    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let appLogsDirectory = documentsDirectory.appendingPathComponent("AppLogs", isDirectory: true)

    if !fileManager.fileExists(atPath: appLogsDirectory.path) {
        try? fileManager.createDirectory(at: appLogsDirectory, withIntermediateDirectories: true)
    }

    return appLogsDirectory.appendingPathComponent("cpu_memory_usage.json")
}


func appendRecordToJsonFile(memoryInfo: (used: String, total: String), cpuUsage: Double    ) {
    
    let memoryInfo = getMemoryUsage()
    let cpuUsage = getCPUUsage()
    
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let usageData: [String: Any] = [
        "timestamp": timestamp,
        "cpu_usage": cpuUsage,
        "memory_used": memoryInfo.used,
        "total_memory": memoryInfo.total
    ]
    
    let fileURL = getUsageFilePath()
    
    var records: [[String: Any]] = []
    
    if let existingData = try? Data(contentsOf: fileURL),
       let existingJSON = try? JSONSerialization.jsonObject(with: existingData, options: []) as? [[String: Any]] {
        records = existingJSON
    }
    
    records.append(usageData)
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: records, options: .prettyPrinted)
        try jsonData.write(to: fileURL, options: .atomic)
    } catch {
        print("Failed to write JSON: \(error.localizedDescription)")
    }
}
