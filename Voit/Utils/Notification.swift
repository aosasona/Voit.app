//
//  Notification.swift
//  Voit
//
//  Created by Ayodeji Osasona on 11/10/2023.
//

import Foundation
import UIKit
import SwiftUI

final class Notification {
    public static let main = Notification()
    
    @AppStorage(AppStorageKey.allowNotifications.rawValue) var allowNotifications: Bool = false
    
    private let center = UNUserNotificationCenter.current()
    
    public var hasPerm: Bool {
        var isAuthorized: Bool = false
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus != .denied && settings.authorizationStatus != .notDetermined { isAuthorized = true }
        }
        
        return isAuthorized && allowNotifications
    }
    
    public func trigger(title: String, subtitle: String, body: String? = nil) {
        if !self.hasPerm { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request)
    }
}
