//
//  Notification.swift
//  Voit
//
//  Created by Ayodeji Osasona on 11/10/2023.
//

import Foundation
import SwiftUI
import UIKit

final class NotificationService {
    @AppStorage(AppStorageKey.allowNotifications.rawValue) var allowNotifications: Bool = false
    private let center = UNUserNotificationCenter.current()
    
    public func trigger(title: String, subtitle: String, body: String? = nil) {
        center.getNotificationSettings { settings in
            if !self.allowNotifications || !(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional) { return }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body ?? subtitle
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    print("Failed to trigger notifications: \(error!.localizedDescription)")
                }
            }
        }
    }
}
