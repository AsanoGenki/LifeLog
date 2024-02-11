//
//  BottomButtonView.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI
import FamilyControls

struct BottomButtonView: View {
    @ObservedObject var countDownTimerViewModel: CountDownTimerViewModel
    @EnvironmentObject var appBlockViewModel: AppBlockViewModel
    @AppStorage(
        "setMinute",
        store: UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")!
    ) var setMinute = 0
    let userdefaults = UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")
    @AppStorage("strictLevel") var strictLevel = 1
    @Binding var endDate: Date
    @Binding var showingSaveAlert: Bool
    @AppStorage("countDownIsOn") var countDownIsOn = false
    @AppStorage("appBlockAuthority") var appBlockAuthority = false
    let showWidget = WidgetController()
    var body: some View {
        HStack {
            Spacer()
            if countDownIsOn == false {
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("todayBackground"))
                    .background(
                        Circle()
                            .stroke(Color("todayBackground"), lineWidth: 3)
                            .frame(width: 60, height: 60)
                    )
                    .onTapGesture {
//                        setMinute = countDownTimerViewModel.countDownMinute
                        userdefaults!.set(setMinute, forKey: "setMinute")
                        countDownTimerViewModel.start(minutes: setMinute)
                        showWidget.showCountDownWidget(title: "Timer", icon: "clock", startTimerDate: Date())
                        appBlockViewModel.blockApp()
                        if strictLevel == 3 {
                            appBlockViewModel.denyAppRemoval()
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 10)
            } else {
                Image(systemName: "square.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("todayBackground"))
                    .background(
                        Circle()
                            .stroke(Color("todayBackground"), lineWidth: 3)
                            .frame(width: 60, height: 60)
                    )
                    .opacity(strictLevel == 1 ? 1 : 0.6)
                    .onTapGesture {
                        if strictLevel == 1 {
                            showingSaveAlert = true
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 10)
            }
            Spacer()
        }
    }
    func authorize() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            appBlockAuthority = true
        } catch {
            appBlockAuthority = false
        }
    }
}

struct BottomButtonView_Previews: PreviewProvider {
    @State static var minute: Int = 0
    @State static var offset: CGFloat = 0
    @State static var endDate: Date = Date()
    @State static var showingSaveAlert = false
    static var previews: some View {
        BottomButtonView(
            countDownTimerViewModel: CountDownTimerViewModel(),
            endDate: $endDate,
            showingSaveAlert: $showingSaveAlert)
    }
}
