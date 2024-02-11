//
//  CountUpTimerModel.swift
//  LifeLog
//
//  Created by Genki on 2/10/24.
//

import Combine
import SwiftUI

struct CountUpTimerModel {
    var elapsedTime = 0
    var startTime: Date?
    var timer: AnyCancellable?
    @AppStorage("timerTab") var timerTab: TimerTab = .countUp
    mutating func changeTimerTab(selectedtab: TimerTab) {
        timerTab = selectedtab
    }
    mutating func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "startTime")
        }
    }
    mutating func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "startTime") as? Date
    }
}
enum TimerTab: String, CaseIterable {
    case countUp, countDown
    var text: String {
        switch self {
        case .countUp:
            return "Count Up"
        case .countDown:
            return "Timer"
        }
    }
}
