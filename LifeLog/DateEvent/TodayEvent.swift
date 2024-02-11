//
//  TodayEvent.swift
//  LifeLog
//
//  Created by Genki on 1/17/24.
//

import SwiftUI

struct TodayEvent: View {
    @EnvironmentObject private var weekStore: WeekCalendarManager
    @AppStorage("showCalendar") var showCalendar = false
    @State private var showCreateCalendar = false
    @State var title = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var createDate = UUID()
    @State var showSearch = false
    @State var showPremium = false
    @State var showSettings = false
    @State var showDatePicker = false
    @EnvironmentObject private var entitlementManager: EntitlementManager
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    var body: some View {
        VStack {
            DateEventHeader(
                showDatePicker: $showDatePicker,
                showSearch: $showSearch,
                showCalendar: $showCalendar,
                showSettings: $showSettings
            )
            WeeklyCalendarView(
                snappedItem: $weekStore.snappedItem,
                draggingItem: $weekStore.draggingItem
            )
            EventDetailView(
                date: $weekStore.currentDate
            )
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let offset = value.predictedEndTranslation.width
                        let direction = offset > 0 ? -1 : 1
                        if let newDate = Calendar.current.date(
                            byAdding: .day,
                            value: direction,
                            to: weekStore.currentDate) {
                            let dayOfWeek = Calendar.current.component(.weekday, from: newDate)
                            if (direction == 1 && dayOfWeek == 1) || (direction == -1 && dayOfWeek == 7) {
                                weekStore.draggingItem = weekStore.snappedItem - Double(direction)
                                weekStore.snappedItem = weekStore.draggingItem
                                weekStore.updateWeekDays(index: Int(weekStore.snappedItem), direction: direction)
                            }
                            if newDate > oneYearAgo || entitlementManager.hasPro {
                                self.weekStore.currentDate = newDate
                            } else {
                                showPremium = true
                            }
                        }
                    }
            )
        }
        .fullScreenCover(isPresented: $showCalendar) {
            CalendarMainView(calendar: Calendar.current, monthsLayout: .horizontal)
        }
        .sheet(isPresented: $showCreateCalendar) {
            NavigationStack {
                CreateEventView(title: $title, startDate: $startDate, endDate: $endDate, createDate: $createDate)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .fullScreenCover(isPresented: $showPremium, onDismiss: {
            showPremium = false
        }, content: {
            PremiumView()
        })
        .sheet(isPresented: $showSettings) {
            SettingView()
        }
        .sheet(isPresented: $showDatePicker) {
            DetailDatePickerView(showDatePicker: $showDatePicker)
                .presentationDetents([.height(!entitlementManager.hasPro ? 340 : 265)])
        }
    }
}
