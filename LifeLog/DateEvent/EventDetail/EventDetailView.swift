//
//  EventDetailView.swift
//  LifeLog
//
//  Created by Genki on 10/30/23.
//

import SwiftUI
import CoreData

struct EventDetailView: View {
    @Binding var date: Date
    @State private var showEditCalendar = false
    @State private var createDate = UUID()
    @State private var showCreateCalendar = false
    @State private var adequancy = -1
    @State private var showDialy = false
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var itemAdequancy: Double = 50.0
    @State private var color: Color = .purple
    @State private var memo: String = ""
    @State private var id: UUID = UUID()
    @State private var calendarID = UUID()
    @AppStorage("selectionTab") var selection: Tab = .calendar
    @AppStorage("displayDate") var displayDate = Date()
    @AppStorage("pieChartDate") var pieChartDate = Date()
    @AppStorage("chartDateTab") var chartDateTab: DateTab = .day
    @AppStorage("pieChartDateTab") var pieChartDateTab: DateTab = .day
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\CalendarItem.startDate)
    ]) var calendarItem: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                EventDetailDiary(date: $date, showDiary: $showDialy, items: getDateItem(date: date))
                    .padding(.top, 5)
                HStack(spacing: 20) {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "chart.pie")
                        Text("Chart")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .onTapGesture {
                        pieChartDate = date
                        selection = .pie
                        pieChartDateTab = .day
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "chart.dots.scatter")
                        Text("Insights")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .onTapGesture {
                        chartDateTab = .day
                        displayDate = date
                        selection = .chart
                    }
                }
                ForEach(getCalendarItem(date: date), id: \.self) { event in
                    if let eventColor = event.tag?.color,
                       let eventTitle = event.title,
                       let eventStartDate = event.startDate,
                       let eventEndDate = event.endDate,
                       let eventMemo = event.memo {
                        HStack {
                            VStack(spacing: 3) {
                                Text(timeString(date: eventStartDate))
                                Text(timeString(date: eventEndDate))
                            }
                            .font(.system(size: 15))
                            .frame(width: 45)
                            Rectangle()
                                .frame(width: 4, height: 34)
                                .cornerRadius(100)
                                .foregroundColor(convertDataToColor(data: eventColor))
                            VStack(alignment: .leading) {
                                Text(eventTitle)
                                    .font(eventTitle.count < 20 ? .system(size: 18) : .system(size: 14))
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
                            }
                            Spacer()
                            HStack {
                                if Int(event.adequancy) != -1 {
                                    returnFace(adequancy: Int(event.adequancy))
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("\(event.adequancy)")
                                        .font(.system(size: 14))
                                } else {
                                    Image("noFace")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("-")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            title = eventTitle
                            itemAdequancy = Double(event.adequancy)
                            startDate = eventStartDate
                            endDate = eventEndDate
                            color = convertDataToColor(data: eventColor) ?? .purple
                            memo = eventMemo
                            id = event.id ?? UUID()
                            if let eventTagId = event.tag?.id {
                                calendarID = eventTagId
                            }
                            showEditCalendar.toggle()
                        }
                    }
                }
                HStack {
                    Image(systemName: "plus")
                    Text("New Event")
                        .font(.title3)
                    Spacer()
                }
                .foregroundColor(.primary)
                .frame(height: 30)
                .padding()
                .background(Color(UIColor.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    title = ""
                    var startComponents = DateComponents(year: Calendar.current.component(.year, from: date),
                                                         month: Calendar.current.component(.month, from: date),
                                                         day: Calendar.current.component(.day, from: date),
                                                         hour: Calendar.current.component(.hour, from: Date()),
                                                         minute: Calendar.current.component(.minute, from: Date())
                    )
                    startComponents.hour! -= 1
                    startDate =  Calendar(identifier: .gregorian).date(from: startComponents)!
                    endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
                    showCreateCalendar.toggle()
                }
                Rectangle()
                    .frame(width: 1, height: 50)
                    .foregroundColor(.clear)
                    .sheet(isPresented: $showCreateCalendar) {
                        NavigationStack {
                            CreateEventView(
                                title: $title,
                                startDate: $startDate,
                                endDate: $endDate,
                                createDate: $createDate
                            )
                        }
                    }
                Spacer()
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .foregroundColor(Color(UIColor.systemBackground))
            }
            .padding(.horizontal)
            .onChange(of: createDate) { _ in
                var totalAdequancy = 0
                for item in getCalendarItem(date: date) where item.adequancy != -1 {
                    totalAdequancy += Int(item.adequancy)
                }
                if getCalendarItem(date: date).count != 0 {
                    adequancy = totalAdequancy / getCalendarItem(date: date).count
                }
            }
            .sheet(isPresented: $showEditCalendar) {
                EditEventView(
                    adequancy: $itemAdequancy,
                    calendarID: $calendarID,
                    createDate: $createDate,
                    endDate: $endDate,
                    id: $id, memo: $memo,
                    startDate: $startDate,
                    title: $title
                )
            }
            .fullScreenCover(isPresented: $showDialy) {
                DiaryEditView(date: $date)
            }
        }
    }
    private func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return calendarItem
    }
    private func getDateItem(date: Date) -> FetchedResults<DateItem>? {
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
