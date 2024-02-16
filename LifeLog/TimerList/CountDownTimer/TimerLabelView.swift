//
//  TimerLabelView.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI

struct TimerLabelView: View {
    @Binding var offset: Double
    @AppStorage("countDownIsOn") var countDownIsOn = false
    @ObservedObject var countDownTimerViewModel: CountDownTimerViewModel
    var body: some View {
        if countDownIsOn == false {
            if Int(sliderOffsetToString(offset: offset))! < 60 {
                Text("\(sliderOffsetToString(offset: offset)) : 00")
                    .font(.system(size: 46).monospacedDigit())
                    .foregroundColor(Color("todayBackground"))
            } else {
                let hours = Int(sliderOffsetToString(offset: offset))! / 60
                let minutes = Int(sliderOffsetToString(offset: offset))!
                - (Int(sliderOffsetToString(offset: offset))! / 60) * 60
                let minuteStamp = String(String(minutes).count > 1 ? String(minutes) : "0" + String(minutes))
                Text("\(hours) : \(minuteStamp) : 00")
                    .font(.system(size: 46).monospacedDigit())
                    .foregroundColor(Color("todayBackground"))
            }
        } else {
            Text(intToTimeLabel(countDownTimerViewModel.timeLeft))
                    .font(.system(size: 46).monospacedDigit())
                    .foregroundColor(Color("todayBackground"))
        }
    }
    private func intToTimeLabel(_ result: Int) -> String {
        if result < 0 {
            let positiveResult = abs(result)
            let seconds = String(positiveResult % 60)
            let minutes = String((positiveResult / 60) % 60)
            let hours = String(positiveResult / 3600)
            let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
            let hoursStamp = hours.count > 1 ? "+" + hours + ":" : "+"
            let secondsStamp = String(seconds.count > 1 ? seconds : "0" + seconds)
            return "\(hoursStamp)\(minuteStamp):\(secondsStamp)"
        } else {
            let seconds = String(result % 60)
            let minutes = String((result / 60) % 60)
            let hours = String(result / 3600)
            let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
            let hoursStamp = hours.count > 1 ? hours : "0" + hours
            let secondsStamp = String(seconds.count > 1 ? seconds : "0" + seconds)
            if result / 3600 < 1 {
                return "\(minuteStamp) : \(secondsStamp)"
            } else {
                return "\(hoursStamp) : \(minuteStamp) : \(secondsStamp)"
            }
        }
    }
}
func intToTimeLabel(_ result: Int) -> String {
    if result < 0 {
        let positiveResult = abs(result)
        let seconds = String(positiveResult % 60)
        let minutes = String((positiveResult / 60) % 60)
        let hours = String(positiveResult / 3600)
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let hoursStamp = hours.count > 1 ? "+" + hours + ":" : "+"
        let secondsStamp = String(seconds.count > 1 ? seconds : "0" + seconds)
        return "\(hoursStamp)\(minuteStamp):\(secondsStamp)"
    } else {
        let seconds = String(result % 60)
        let minutes = String((result / 60) % 60)
        let hours = String(result / 3600)
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let hoursStamp = hours.count > 1 ? hours : "0" + hours
        let secondsStamp = String(seconds.count > 1 ? seconds : "0" + seconds)
        if result / 3600 < 1 {
            return "\(minuteStamp) : \(secondsStamp)"
        } else {
            return "\(hoursStamp) : \(minuteStamp) : \(secondsStamp)"
        }
    }
}

struct TimerLabelView_Previews: PreviewProvider {
    @State static var offset: Double = 0
    @State static var result: Int = 0
    @StateObject static var countDownTimerViewModel = CountDownTimerViewModel()
    static var previews: some View {
        TimerLabelView(offset: $offset, countDownTimerViewModel: countDownTimerViewModel)
    }
}
