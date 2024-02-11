//
//  TimerNotificationViewModel.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI
import UserNotifications

class TimerNotificationViewModel: ObservableObject {
    func timerEndNotification(minutes: Int) {
        let notificationDate = Date().addingTimeInterval(TimeInterval(minutes))
        let dateComp = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: notificationDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
            let content = UNMutableNotificationContent()
            content.title = "AppBlockTimer"
            content.body = "タイマーが終了しました！"
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: "timerEndNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    func deletetimerEndNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
