//
//  widgetController.swift
//  LifeLog
//
//  Created by Genki on 11/12/23.
//

import SwiftUI
import ActivityKit

struct WidgetController {
    @AppStorage("currentID") var currentID: String = ""
    @State var activity: Activity<CountUpWidgetAttributes>?
    @AppStorage("widgetTitle") var widgetTitle = ""
    @AppStorage("widgetIcon") var widgetIcon = ""
    func showCountUpWidget(title: String, icon: String, startTimerDate: Date) {
        widgetTitle = title
        widgetIcon = icon
        let attribute = CountUpWidgetAttributes()
        let state = CountUpWidgetAttributes.ContentState(title: title, icon: icon, startDate: startTimerDate)
        do {
            if #available(iOS 16.2, *) {
               let activity = try Activity<CountUpWidgetAttributes>.request(
                attributes: attribute, content: ActivityContent<Activity<CountUpWidgetAttributes>.ContentState>.init(
                    state: state,
                    staleDate: nil), pushType: nil)
                currentID = activity.id

            } else {
                let activity = try Activity.request(attributes: attribute, contentState: state, pushType: nil)
                currentID = activity.id
            }
        } catch {
       }
    }
    func showCountDownWidget(title: String, icon: String, startTimerDate: Date) {
        widgetTitle = title
        widgetIcon = icon
        let attribute = CountDownWidgetAttributes()
        let state = CountDownWidgetAttributes.ContentState(title: title, icon: icon, startDate: startTimerDate)
        do {
            if #available(iOS 16.2, *) {
               let activity = try Activity<CountDownWidgetAttributes>.request(
                attributes: attribute, content: ActivityContent<Activity<CountDownWidgetAttributes>.ContentState>.init(
                    state: state,
                    staleDate: nil), pushType: nil)
                currentID = activity.id

            } else {
                let activity = try Activity.request(attributes: attribute, contentState: state, pushType: nil)
                currentID = activity.id
            }
        } catch {
       }
    }

    func hideCountUpWidget() {
        if let activity = Activity.activities.first(where: { (activity: Activity<CountUpWidgetAttributes>) in
            activity.id == currentID
        }) {
            Task {
                await activity.end(activity.content, dismissalPolicy: .immediate)
            }} else {}}
    func hideCountDownWidget() {
        if let activity = Activity.activities.first(where: { (activity: Activity<CountDownWidgetAttributes>) in
            activity.id == currentID
        }) {
            Task {
                await activity.end(activity.content, dismissalPolicy: .immediate)
            }
        } else {
        }
    }
}
