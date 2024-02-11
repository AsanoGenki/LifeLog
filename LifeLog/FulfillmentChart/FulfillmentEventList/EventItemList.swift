//
//  EventItemList.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import CoreData

struct EventItemList: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\CalendarItem.startDate, order: .reverse)
    ]) var eventItems: FetchedResults<CalendarItem>
    @ObservedObject var viewModel: ChartViewModel
    @Binding var displayDate: Date
    @State var title = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var itemFulfillment: Double = 50.0
    @State var color: Color = .purple
    @State var memo = ""
    @State var id: UUID = UUID()
    @State var calendarID = UUID()
    @State var createDate = UUID()
    @State var showCalendarView = false
    var body: some View {
        LazyVStack {
            ForEach(returnEventItem(date: displayDate)) { event in
                if let eventColor = event.tag?.color,
                   let eventTitle = event.title,
                   let eventStartDate = event.startDate,
                   let eventEndDate = event.endDate,
                   let eventMemo = event.memo {
                    HStack {
                        Rectangle()
                            .frame(width: 4, height: 34)
                            .cornerRadius(100)
                            .foregroundColor(convertDataToColor(data: eventColor))
                        VStack(alignment: .leading) {
                            Text(eventTitle)
                                .lineLimit(2)
                            if eventMemo != "" {
                                HStack(spacing: 2) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 10))
                                    Text(eventMemo)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.gray)
                                        .lineLimit(1)
                                }
                            }
                            Text(eventItemDate(startDate: eventStartDate, endDate: eventEndDate))
                                .font(.system(size: 10))
                                .foregroundStyle(Color(UIColor.systemGray))
                        }
                        Spacer()
                        if Int(event.adequancy) != -1 {
                            HStack {
                                returnFace(adequancy: Int(event.adequancy))
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("\(event.adequancy)")
                                    .font(.system(size: 14))
                            }
                        } else {
                            HStack {
                                Image("noFace")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("-")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(UIColor.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        title = eventTitle
                        itemFulfillment = Double(event.adequancy)
                        startDate = eventStartDate
                        endDate = eventEndDate
                        color = convertDataToColor(data: eventColor) ?? .purple
                        memo = eventMemo
                        id = event.id ?? UUID()
                        if let eventTagId = event.tag?.id {
                            calendarID = eventTagId
                        }
                        showCalendarView.toggle()
                    }
                    .sheet(isPresented: $showCalendarView) {
                        EditEventView(
                            adequancy: $itemFulfillment,
                            calendarID: $calendarID,
                            createDate: $createDate,
                            endDate: $endDate,
                            id: $id, memo: $memo,
                            startDate: $startDate,
                            title: $title
                        )
                    }
                }
            }
        }
        .onChange(of: viewModel.eventListSort) { _ in
            if viewModel.eventListSort == .recently {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate, order: .reverse)]
            } else if viewModel.eventListSort == .old {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate)]
            } else if viewModel.eventListSort == .high {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy, order: .reverse)]
            } else if viewModel.eventListSort == .low {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy)]
            }
        }
        .onAppear {
            if viewModel.eventListSort == .recently {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate, order: .reverse)]
            } else if viewModel.eventListSort == .old {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate)]
            } else if viewModel.eventListSort == .high {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy, order: .reverse)]
            } else if viewModel.eventListSort == .low {
                eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy)]
            }
        }
    }
    private func returnEventItem(date: Date) -> FetchedResults<CalendarItem> {
        switch viewModel.eventListSort {
        case .recently:
            eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate, order: .reverse)]
        case .old:
            eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.startDate)]
        case .high:
            eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy, order: .reverse)]
        case .low:
            eventItems.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy)]
        }
        if viewModel.selectedDateTab == .day {
            return getCalendarItems(date: date)
        } else if viewModel.selectedDateTab == .week {
            return getWeekCalendarItems(date: date)
        } else if viewModel.selectedDateTab == .month {
            return getMonthCalendarItems(date: date)
        } else if viewModel.selectedDateTab == .sixMonth {
            return getHalfYearCalendarItems(date: date)
        }
        return eventItems
    }
    private func getCalendarItems(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        eventItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        if viewModel.filterTag != nil {
            let predicate2 = NSPredicate(format: "tag.id == %@", viewModel.filterTag! as CVarArg)
            eventItems.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        } else {
            eventItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        }
        return eventItems
    }
    func getWeekCalendarItems(date: Date) -> FetchedResults<CalendarItem> {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let sunday = calendar.date(from: components)!
        let saturday = calendar.date(byAdding: .day, value: 6, to: sunday)!
        let startDate = calendar.startOfDay(for: sunday)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: saturday)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        if viewModel.filterTag != nil {
            let predicate2 = NSPredicate(format: "tag.id == %@", viewModel.filterTag! as CVarArg)
            eventItems.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        } else {
            eventItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        }
        return eventItems
    }
    private func getMonthCalendarItems(date: Date) -> FetchedResults<CalendarItem> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let lastDayOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: firstDayOfMonth)!
        let startDate = calendar.startOfDay(for: firstDayOfMonth)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDayOfMonth)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        if viewModel.filterTag != nil {
            let predicate2 = NSPredicate(format: "tag.id == %@", viewModel.filterTag! as CVarArg)
            eventItems.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        } else {
            eventItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        }
        return eventItems
    }
    private func getHalfYearCalendarItems(date: Date) -> FetchedResults<CalendarItem> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year!
        var startDate: Date
        var endDate: Date
        if components.month! <= 6 {
            startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            endDate = calendar.date(from: DateComponents(year: year, month: 6, day: 30))!
        } else {
            startDate = calendar.date(from: DateComponents(year: year, month: 7, day: 1))!
            endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        }
        startDate = calendar.startOfDay(for: startDate)
        endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        if viewModel.filterTag != nil {
            let predicate2 = NSPredicate(format: "tag.id == %@", viewModel.filterTag! as CVarArg)
            eventItems.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        } else {
            eventItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        }
        return eventItems
    }
}
