//
//  WeekView.swift
//  LifeLog
//
//  Created by Genki on 1/17/24.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @EnvironmentObject var weekStore: WeekCalendarManager
    @Binding var snappedItem: Double
    @Binding var draggingItem: Double
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    var body: some View {
        ZStack {
            ForEach(weekStore.allWeeks) { week in
                VStack {
                    HStack {
                        ForEach(0..<7) { index in
                            VStack(spacing: 10) {
                                Text(weekStore.dateToString(date: week.date[index], format: "EEEEE"))
                                    .font(.system(size: 10))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                Text(weekStore.dateToString(date: week.date[index], format: "d"))
                                    .font(.system(size: 18))
                                    .fontWeight(.regular)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(weekStore.isSelectDate(date: week.date[index]) ?
                                                     Color("todayFontColor") :
                                                        weekStore.isToday(date: week.date[index]) ?
                                                     Color(UIColor.todayBackground) : .primary)
                                    .background(
                                        Circle()
                                            .fill(
                                                weekStore.isSelectDate(date: week.date[index]) &&
                                                weekStore.isToday(date: week.date[index]) ?
                                                Color(UIColor.todayBackground) :
                                                    weekStore.isSelectDate(date: week.date[index]) ?
                                                Color.primary : Color("whiteBlack")
                                            )
                                            .frame(
                                                width: weekStore.isSelectDate(date: week.date[index]) ? 32 : 38,
                                                height: weekStore.isSelectDate(date: week.date[index]) ? 32 : 38
                                            )
                                    )
                                EmotionFaceView(items: getDateItem(date: week.date[index]))
                            }
                            .onTapGesture {
                                weekStore.currentDate = week.date[index]
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .background(
                        Rectangle()
                            .fill(Color("whiteBlack"))
                            .padding()
                            .background(Color("whiteBlack"))
                    )
                }
                .offset(x: weekStore.myXOffset(week.id), y: 0)
                .zIndex(1.0 - abs(weekStore.distance(week.id)) * 0.1)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.predictedEndTranslation.width > 0 {
                        weekStore.currentDate = Calendar.current.date(
                            byAdding: .day, value: -7,
                            to: weekStore.currentDate) ?? Date()
                        weekStore.initWeeklyCalendar()
                    } else {
                        weekStore.currentDate = Calendar.current.date(
                            byAdding: .day, value: +7,
                            to: weekStore.currentDate) ?? Date()
                        weekStore.initWeeklyCalendar()
                    }
                }
        )
    }
    private func getDateItem(date: Date) -> FetchedResults<DateItem> {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let predicate = NSPredicate(format: "(%@ <= date) AND (date <= %@)", targetDate as NSDate, targetDate as NSDate)
        dateItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return dateItem
    }
}
