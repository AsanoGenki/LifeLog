//
//  CountDownTimerModel.swift
//  LifeLog
//
//  Created by Genki on 2/10/24.
//

import Combine
import SwiftUI

struct CountDownTimerModel {
    @AppStorage(
        "setMinute",
        store: UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")!
    )var setMinute = 0
    var timeLeft = 0
    var startTime: Date?
//    var countDownMinute = 15
    var timer: AnyCancellable?
    mutating func changeCountDownMinute(minutes: Int) {
        setMinute = minutes
    }
    mutating func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "countDownStartTime") as? Date
    }
    mutating func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "countDownStartTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "countDownStartTime")
        }
    }
}
