//
//  QuickTimer.swift
//  LifeLog
//
//  Created by Genki on 10/31/23.
//

import SwiftUI

struct QuickTimer: View {
    @Binding var showStartQuickTimer: Bool
    @AppStorage("quickTimerName") var quickTimerName: String = ""
    @AppStorage("timerID") var timerID: UUID?
    let userdefaults = UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")
    var body: some View {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        HStack {
            VStack(alignment: .center) {
                HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 24))
                            .foregroundColor(Color("iconColor"))
                            .frame(width: 36)
                        Text("Quick Timer")
                        .font(.system(size: width * 0.06))
                    Spacer()
                }
                Button {
                    quickTimerName = ""
                    userdefaults!.set("", forKey: "countUpTimer")
                    timerID = UUID()
                    showStartQuickTimer.toggle()
                } label: {
                    HStack {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 16))
                        Text("Start")
                            .font(.system(size: width * 0.06))
                    }
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color("buttonColor"))
                        .foregroundColor(Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)))
                        .cornerRadius(16)
                }.font(.system(size: 50))
            }
            }
        .padding(20)
        .frame(maxHeight: .infinity)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("borderColor"), lineWidth: 0.5)
        )
    }
}

struct QuickTimer_Previews: PreviewProvider {
    @State static var showStartQuickTimer = false
    static var previews: some View {
        QuickTimer(showStartQuickTimer: $showStartQuickTimer)
    }
}
