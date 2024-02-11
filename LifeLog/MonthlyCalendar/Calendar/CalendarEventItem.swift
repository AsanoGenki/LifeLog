//
//  CalendarEventItem.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import CoreData
import HorizonCalendar

struct CalendarEventItem: View {
    let items: FetchedResults<CalendarItem>
    let circleColor: Color
    let numberColor: Color
    let day: DayComponents
    var body: some View {
        VStack(spacing: 2) {
            Divider()
            ZStack(alignment: .center) {
                Circle().foregroundColor(circleColor)
                    .frame(width: 20, height: 20)
                Text("\(day.day)")
                    .foregroundColor(numberColor)
                    .font(.system(size: 12))
            }
            VStack(alignment: .leading, spacing: 2) {
                ForEach(items.prefix(day.day <= 29 ? 5 : 4), id: \.self) { event in
                    if let eventTitle = event.title, let eventColor = event.tag?.color {
                        Text(MonthlyEventText().processText(eventTitle))
                            .foregroundColor(convertDataToColor(data: eventColor))
                            .font(.system(size: 9.6))
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: (UIScreen.main.bounds.height * 0.055) / 3.5)
                            .padding(.trailing, 2)
                            .background(convertDataToColor(data: eventColor).opacity(0.2).cornerRadius(2))
                            .padding(.horizontal, 1)
                    }
                }
            }
            Spacer()
        }
        .frame(height: 120)
    }
}
