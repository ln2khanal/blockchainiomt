//
//  NotificationManager.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 24/02/2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Blockchain Update"
        content.body = "Vitals pushed to the blockchain."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
//            everything is alright
        }
    }
}
