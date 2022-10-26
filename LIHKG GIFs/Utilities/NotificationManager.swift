//
//  NotificationManager.swift
//  LIHKG GIFs
//
//  Created by Ice Lam on 27/10/2022.
//

import UserNotifications

class NotificationManager: NSObject {
  static func send(title: String, body: String, delay: Double = 0) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    let trigger = delay > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false) : nil
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(
      request,
      withCompletionHandler: { (errorObject) in
        if let error = errorObject{
          NSLog("Unable to add notification request (\(error), \(error.localizedDescription))")
        }
      })
  }
}
