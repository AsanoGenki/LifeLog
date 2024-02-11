//
//  TimerViewModel.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import Combine
import SwiftUI

class CountDownTimerViewModel: ObservableObject {
    @Published var model: CountDownTimerModel = CountDownTimerModel()
    var startTime: Date? {
        model.startTime
    }
    var timeLeft: Int {
        model.timeLeft
    }
//    var countDownMinute: Int {
//        model.countDownMinute
//    }
    @ObservedObject var notificationViewModel = TimerNotificationViewModel()
    @AppStorage(
        "setMinute",
        store: UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")!
    )var setMinute = 0
    @AppStorage("startDate") var startTimerDate = Date()
    @AppStorage("countDownIsOn") var countDownIsOn = false
    @AppStorage("timerIsMinus") var timerIsMinus = false
    let showWidget = WidgetController()
    var appBlockModel: AppBlockModel = AppBlockModel()
    init() {
        model.startTime = model.fetchStartTime()
        if model.startTime != nil {
            start(minutes: setMinute)
        }
    }
    func changeCountDownMinute(minutes: Int) {
        model.changeCountDownMinute(minutes: minutes)
    }
    func start(minutes: Int) {
        setMinute = minutes
        startTimerDate = Date()
        model.timer?.cancel()
        countDownIsOn = true
        let seconds = minutes * 60
        let totalTime = Double(seconds)
        notificationViewModel.timerEndNotification(minutes: seconds)
        if model.startTime == nil {
            model.startTime = Date()
            model.saveStartTime()
        }
        model.timer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                let now = Date()
                let elapsed = now.timeIntervalSince(startTime)
                self.model.timeLeft = Int(totalTime - elapsed)
            }
    }
    func stop() {
        model.timer?.cancel()
        countDownIsOn = false
        model.startTime = nil
        model.saveStartTime()
        model.timeLeft = 0
        notificationViewModel.deletetimerEndNotification()
        showWidget.hideCountDownWidget()
        appBlockModel.unBlockApp()
        appBlockModel.undenyAppRemoval()
        timerIsMinus = false
    }
    func end() {
        model.timer?.cancel()
        countDownIsOn = false
        model.startTime = nil
        model.saveStartTime()
        model.timeLeft = 0
        timerIsMinus = false
        showWidget.hideCountDownWidget()
        appBlockModel.unBlockApp()
        appBlockModel.undenyAppRemoval()
    }
    func elapsedTimeToCircle(_ result: Int) -> Double {
        let totalTime = setMinute * 60
        return (Double(totalTime) - Double(result)) / Double(totalTime)
    }
}
