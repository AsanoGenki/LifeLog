//
//  TimeCircleView.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI

struct TimeCircleView: View {
    @ObservedObject var countDownTimerViewModel: CountDownTimerViewModel
    @AppStorage("countDownIsOn") var countDownIsOn = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("todayBackground").opacity(0.4), style: StrokeStyle(lineWidth: 10))
                .scaledToFit()
                .padding(10)
            Circle()
                .trim(
                    from: 0.0,
                    to: 1.0 - countDownTimerViewModel.elapsedTimeToCircle(
                        Int(countDownTimerViewModel.timeLeft)
                    )
                )
                .stroke(
                    countDownIsOn != false ? Color("todayBackground") : Color("todayBackground").opacity(0.4),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .scaledToFit()
                .padding(10)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: countDownTimerViewModel.timeLeft)
        }
    }
}

struct TimeCircleView_Previews: PreviewProvider {
    static var previews: some View {
        TimeCircleView(countDownTimerViewModel: CountDownTimerViewModel())
    }
}
