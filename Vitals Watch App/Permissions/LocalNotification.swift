//
//  UserNotifications.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 24/02/2025.
//

import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if let error = error {
            print("Error requesting notification permission: \(error.localizedDescription)")
        } else {
            print("Notification permission granted: \(granted)")
        }
    }
}
