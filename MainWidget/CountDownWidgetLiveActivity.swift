//
//  TimerWidgetLiveActivity.swift
//  LifeLog
//
//  Created by Genki on 1/24/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CountDownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var icon: String
        var startDate: Date
    }
}

struct CountDownWidgetLiveActivity: Widget {
    let userdefaults = UserDefaults(
        suiteName: "group.com.DeviceActivityMonitorExtension")
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountDownWidgetAttributes.self) { context in
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.black.opacity(0.7))
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: context.state.icon)
                            Text(userdefaults!.string(forKey: "timerTitle") == "" ?
                                 "Timer": userdefaults!.string(forKey: "timerTitle")
                                 ?? "Timer")
                            Spacer()
                        }.foregroundColor(Color("iconColor"))
                        HStack {
                            let components = DateComponents(minute: userdefaults!.integer(forKey: "setMinute"))
                            let futureDate = Calendar.current.date(byAdding: components, to: Date())!
                            Text(futureDate, style: .timer)
                                .font(.system(size: 42).monospacedDigit())
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    Image(systemName: "stop.circle")
                        .font(.system(size: 36))
                        .foregroundColor(Color("iconColor"))
                }
                .activityBackgroundTint(Color.clear)
                .padding()
            }
            .preferredColorScheme(.dark)
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                }
                DynamicIslandExpandedRegion(.trailing) {
                }
                DynamicIslandExpandedRegion(.bottom) {
                }
            } compactLeading: {
            } compactTrailing: {
            } minimal: {
            }
        }
    }
}
