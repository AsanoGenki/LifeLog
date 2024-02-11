//
//  MainWidgetLiveActivity.swift
//  MainWidget
//
//  Created by Genki on 12/27/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CountUpWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var icon: String
        var startDate: Date
    }
}

struct CountUpWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountUpWidgetAttributes.self) { context in
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.black.opacity(0.7))
                HStack {
                    VStack {
                        HStack {
                            Image(systemName: context.state.icon)
                            Text(context.state.title == "" ? "Timer" : "\(context.state.title)")
                            Spacer()
                        }.foregroundColor(Color("iconColor"))
                        HStack {
                            Text(
                                Date(
                                    timeIntervalSinceNow: Double(
                                        context.state.startDate.timeIntervalSince1970)
                                    - Date().timeIntervalSince1970
                                ),
                                style: .timer
                            )
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
                DynamicIslandExpandedRegion(.leading) {}
                DynamicIslandExpandedRegion(.trailing) {}
                DynamicIslandExpandedRegion(.bottom) {}
            } compactLeading: {} compactTrailing: {} minimal: {}
        }
    }
}
