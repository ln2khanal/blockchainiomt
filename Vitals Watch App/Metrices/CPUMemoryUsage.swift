//
//  CPUMemoryUsage.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 01/03/2025.
//

import Foundation

func formatMemorySize(_ size: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useGB]
    formatter.countStyle = .memory
    
    return formatter.string(fromByteCount: Int64(size))
}

func getCPUUsage() -> Double {
    var threadsList: thread_act_array_t?
    var threadCount = mach_msg_type_number_t(0)
    
    let result = task_threads(mach_task_self_, &threadsList, &threadCount)
    if result != KERN_SUCCESS { return 0.0 }
    
    var totalCPUUsage: Double = 0.0
    if let threadsList = threadsList {
        for i in 0..<Int(threadCount) {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let result = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                    thread_info(threadsList[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            
            if result == KERN_SUCCESS {
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalCPUUsage += Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
        }
    }
    
    return totalCPUUsage
}

func getMemoryUsage() -> (used: String, total: String) {
    var taskInfo = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: taskInfo) / MemoryLayout<integer_t>.size)

    let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    
    let usedMemory = result == KERN_SUCCESS ? taskInfo.resident_size : 0
    let totalMemory = ProcessInfo.processInfo.physicalMemory
    
    return (formatMemorySize(usedMemory), formatMemorySize(totalMemory))
}

