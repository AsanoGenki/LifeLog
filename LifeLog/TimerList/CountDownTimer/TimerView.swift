//
//  TimerView.swift
//  LifeLog
//
//  Created by Genki on 11/12/23.
//

import SwiftUI

struct TimerView: View {
    @State var endDate = Date()
    @State var showingSaveAlert = false
    @State var showCreateCalendar = false
    @State var title = ""
    @State var createDate = UUID()
    @EnvironmentObject var countDownTimerViewModel: CountDownTimerViewModel
    @AppStorage("timerTitle") var timerTitle = ""
    @AppStorage("timerOffset") var offset: Double = 0
    @AppStorage("startDate") var startTimerDate = Date()
    @AppStorage("countDownIsOn") var countDownIsOn = false
    let userdefaults = UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")
    var body: some View {
            NavigationView {
                VStack {
                    TextField("I'm focusing on...", text: $timerTitle)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .onChange(of: timerTitle) { text in
                            userdefaults!.set(text, forKey: "timerTitle")
                        }
                    ZStack {
                        ZStack(alignment: .center) {
                            TimeCircleView(countDownTimerViewModel: countDownTimerViewModel)
                            TimerLabelView(countDownTimerViewModel: countDownTimerViewModel)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height * 0.38)
                        .padding(36)
                        .padding(.top, -144)
                        VStack(spacing: 12) {
                            Spacer()
                            TimeSliderView(countDownTimerViewModel: countDownTimerViewModel)
                                .opacity(countDownIsOn == false ? 1 : 0)
                            BottomButtonView(
                                countDownTimerViewModel: countDownTimerViewModel,
                                endDate: $endDate,
                                showingSaveAlert: $showingSaveAlert
                            )
                        }
                    }
                }
                .onAppear {
                    userdefaults!.set(timerTitle, forKey: "timerTitle")
                }
                .alert("Would you like to save this record?", isPresented: $showingSaveAlert) {
                    Button("Save", action: {
                        endDate = Date()
                        showCreateCalendar = true
                        countDownTimerViewModel.stop()
                    })
                    Button("Delete", role: .destructive, action: {
                        countDownTimerViewModel.stop()
                    })
                }
                .sheet(isPresented: $showCreateCalendar) {
                    NavigationStack {
                        CreateEventView(
                            title: $timerTitle,
                            startDate: $startTimerDate,
                            endDate: $endDate,
                            createDate: $createDate
                        )
                    }
                }
            }
    }
}
