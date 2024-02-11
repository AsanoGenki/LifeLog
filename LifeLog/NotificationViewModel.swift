//
//  NotificationViewModel.swift
//  LifeLog
//
//  Created by Genki on 11/15/23.
//

import SwiftUI

class NotificationViewModel: ObservableObject {
    @AppStorage("notificationStartTime") var notificationStartTime =
    Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @AppStorage("notificationEndTime") var notificationEndTime =
    Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @AppStorage("repeatTime") var repeatTime = 90
    var notificationDelegate = ForegroundNotificationDelegate()
    init() {
            UNUserNotificationCenter.current().delegate = self.notificationDelegate
        }
    func repeatAlert() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: notificationStartTime)
        let startDate = DateComponents(hour: startComponents.hour, minute: startComponents.minute)
        let endComponents = calendar.dateComponents([.hour, .minute], from: notificationEndTime)
        let endDate = DateComponents(hour: endComponents.hour, minute: endComponents.minute)
        let intervalMinutes = repeatTime
        let repeatCount = abs(endDate.hour! - startDate.hour!)
        let numberOfNotifications = (repeatCount * 60) / intervalMinutes
        var date = startDate
        for _ in 0..<numberOfNotifications + 1 {
            if date.hour! <= endDate.hour! && date.hour! >= startDate.hour! {
                let beforeDate = date
                if let minute = date.minute {
                    date.minute = minute + intervalMinutes
                    if date.minute! >= 60 {
                        let minutes = date.minute
                        date.minute = date.minute! % 60
                        date.hour = date.hour! + (minutes! / 60)
                    }
                }
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

                let content = UNMutableNotificationContent()
                content.title = "LifeLog"
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let startDateString = formatter.string(from: calendar.date(from: beforeDate)!)
                let endDateString = formatter.string(from: calendar.date(from: date)!)
                content.body = NSString.localizedUserNotificationString(forKey: "notification_body",
                                                                        arguments: [startDateString, endDateString])
                content.sound = .default
                let request = UNNotificationRequest(identifier: "notification\(date.hour!)\(date.minute!)",
                                                    content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                print(date)
                print("\(startDateString)~\(endDateString)の記録しよう！")
            }

        }
    }
    func deleteNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
class ForegroundNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping(UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
            let queryString = response.notification.request.identifier
            let url = URL(string: "deeplinktest://deeplink?\(queryString)")
            if let openUrl = url {
                UIApplication.shared.open(openUrl)
            }
            completionHandler()
        }
}
