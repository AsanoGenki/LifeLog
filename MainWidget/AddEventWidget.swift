//
//  circleWidget.swift
//  LifeLog
//
//  Created by Genki on 12/21/23.
//

import WidgetKit
import SwiftUI

struct AddEventWidgetWidgetView: View {
    @Environment(\.widgetFamily) var family
    var body: some View {
        switch family {
        case .accessoryCircular:
            Link(destination: URL(string: "lifelog-scheme://CreateCalendarView")!, label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
            })
            .containerBackground(for: .widget) {
                        Color.white
                    }
        default:
            Text("default")
        }
    }
}

struct AddEventWidget: Widget {
    let kind: String = "AddEventWidgetWidgetView"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            AddEventWidgetWidgetView()
        }
        .configurationDisplayName("AddEvent Widget")
        .description("This is widget for add a event.")
        .supportedFamilies([
            .accessoryCircular
        ])
    }
}

struct AddEventEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AddEventEntry {
        AddEventEntry(date: Date())
    }
    func getSnapshot(in context: Context, completion: @escaping (AddEventEntry) -> Void) {
        let entry = AddEventEntry(date: Date())
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [AddEventEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = AddEventEntry(date: entryDate)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
