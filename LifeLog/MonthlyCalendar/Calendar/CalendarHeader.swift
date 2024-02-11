//
//  CalendarHeader.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import HorizonCalendar
import CoreData

struct CalendarHeader: View {
    let year: Int
    let month: Int
    let nowDay: Int
    let calendar: Calendar
    var calendarViewProxy: CalendarViewProxy
    @Binding var monthTitle: String
    @Binding var showSearch: Bool
    @Binding var showCalendarTypeMenu: Bool
    @Binding var showDatePicker: Bool
    @Binding var showEmoji: Bool
    @Environment(\.managedObjectContext) var managedObjectContext
    @AppStorage("showCalendar") var showCalendar = false
    var body: some View {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        VStack {
            HStack(spacing: 16) {
                Button {
                    showCalendar = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: width * 0.055))
                }.foregroundStyle(.primary)
                Text(monthTitle)
                    .font(.system(size: width * 0.050)
                        .monospacedDigit())
                    .frame(alignment: .leading)
                    .onTapGesture {
                        showDatePicker = true
                    }
                Spacer()
                Button {
                    showSearch.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: width * 0.055))
                }.foregroundStyle(.primary)
                Button {
                    showEmoji.toggle()
                } label: {
                    if !showEmoji {
                        Image(systemName: "face.smiling")
                            .font(.system(size: width * 0.055))
                    } else {
                        Image(systemName: "calendar")
                                    .font(.system(size: width * 0.055))
                    }
                }.foregroundStyle(.primary)
                Button {
                    calendarViewProxy.scrollToMonth(
                        containing: calendar.date(from: DateComponents(year: year, month: month, day: nowDay))!,
                        scrollPosition: .centered,
                        animated: false)
                } label: {
                    Image("todayIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width * 0.052, height: UIScreen.main.bounds.width * 0.052)
                }
                Button {
                    showCalendarTypeMenu.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: width * 0.055))
                }.foregroundStyle(.primary)
            }
            .padding()
            .frame(height: 44)
            Spacer()
        }
    }
    // デベロッパー用
    private func deleteCoreDataAll() {
        let eventTagFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "EventTag")
        let eventTagDeleteRequest = NSBatchDeleteRequest(fetchRequest: eventTagFetchRequest)
        let dateItemFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DateItem")
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        let endDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 31))!
        let datePredicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate, endDate as NSDate)
        dateItemFetchRequest.predicate = datePredicate
        let dateItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: dateItemFetchRequest)
        let timerItemFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TimerItem")
        let timerItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: timerItemFetchRequest)
        let calendarItemFetchRequest:
        NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CalendarItem")
        let calendarItemPredicate = NSPredicate(
            format: "(%@ <= date) AND (date <= %@)",
            startDate as NSDate,
            endDate as NSDate)
        calendarItemFetchRequest.predicate = calendarItemPredicate
        let calendarItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: calendarItemFetchRequest)
        do {
            try self.managedObjectContext.execute(eventTagDeleteRequest)
            try self.managedObjectContext.execute(dateItemDeleteRequest)
            @AppStorage("imageData") var imageData = 0.0
            imageData = 0.0
            try self.managedObjectContext.execute(timerItemDeleteRequest)
            try self.managedObjectContext.execute(calendarItemDeleteRequest)
            try self.managedObjectContext.save()
        } catch {
            print("There was an error")
        }
    }
}
