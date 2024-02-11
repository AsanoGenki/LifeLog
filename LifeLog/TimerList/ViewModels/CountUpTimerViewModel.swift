//
//  CountUpTimerViewModel.swift
//  LifeLog
//
//  Created by Genki on 11/12/23.
//

import Combine
import SwiftUI

class CountUpTimerViewModel: ObservableObject {
    @Published var model: CountUpTimerModel = CountUpTimerModel()
    @AppStorage("countUpisOn") var countUpisOn = false
    @AppStorage("quickTimerName") private var quickTimerName = ""
    @AppStorage("startDate") private var startTimerDate = Date()
    let showWidget = WidgetController()
    var appBlockModel: AppBlockModel = AppBlockModel()
    var elapsedTime: Int {
        model.elapsedTime
    }
    var startTime: Date? {
        model.startTime
    }
    var timerTab: TimerTab {
        model.timerTab
    }
    init() {
        model.startTime = model.fetchStartTime()
        if model.startTime != nil {
            startTimer()
        }
    }
    func changeTimerTab(selectedTab: TimerTab) {
        model.changeTimerTab(selectedtab: selectedTab)
    }
    func startTimer() {
        model.elapsedTime = 0
        if startTime == nil {
            model.startTime = Date()
            model.saveStartTime()
        }
        appBlockModel.blockApp()
        countUpisOn = true
        model.timer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                let now = Date()
                let elapsed = now.timeIntervalSince(startTime)
                self.model.elapsedTime = Int(elapsed)
            }
    }
    func stopTimer() {
        model.timer?.cancel()
        model.elapsedTime = 0
        model.startTime = nil
        model.saveStartTime()
        countUpisOn = false
        showWidget.hideCountUpWidget()
        appBlockModel.unBlockApp()
    }
}
