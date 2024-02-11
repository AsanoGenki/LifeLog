//
//  c.swift
//  Calendar
//
//  Created by Genki on 10/17/23.
//

import HorizonCalendar
import SwiftUI
import EventKit

struct CalendarMainView: View {
    init(calendar: Calendar, monthsLayout: MonthsLayout) {
        self.calendar = calendar
        self.monthsLayout = monthsLayout
        let startDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        visibleDateRange = startDate...endDate
        monthDateFormatter = DateFormatter()
        monthDateFormatter.calendar = calendar
        monthDateFormatter.locale = calendar.locale
        monthDateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current)
        setupAppearance()
    }
    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>
    private let monthDateFormatter: DateFormatter
    private let year = Calendar.current.component(.year, from: Date())
    private let month = Calendar.current.component(.month, from: Date())
    private let nowDay = Calendar.current.component(.day, from: Date())
    private let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    @State private var createDate = UUID()
    @State private var endDate = Date()
    @State private var monthTitle = ""
    @State private var selectedDate: DayComponents?
    @State private var selectedDayRange: DayComponentsRange?
    @State private var showCalendarTypeMenu = false
    @State private var showDatePicker = false
    @State private var showEmoji = false
    @State private var showPremium = false
    @State private var showSearch = false
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    @AppStorage("showCalendar") var showCalendar = false
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\CalendarItem.startDate)]
    ) var calendarItem: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var weekCalendarManager: WeekCalendarManager
    var daysOfWeek: [String] {
        var weeks: [String] = []
        var calendar = Calendar(identifier: .gregorian)
        if Locale.current.language.languageCode?.identifier == "ja" {
            calendar.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
            weeks = calendar.shortWeekdaySymbols
        } else {
            weeks = Calendar(identifier: .gregorian).shortWeekdaySymbols
        }
        return weeks
    }
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        @Environment(\.locale) var locale
        if Locale.current.language.languageCode?.identifier == "ja" {
            dateFormatter.dateFormat = "yyyy年MMM"
        } else {
            dateFormatter.dateFormat = "MMM yyyy"
        }
        return dateFormatter
    }()
    var body: some View {
        NavigationView {
            GeometryReader { _ in
                ZStack {
                    CalendarViewRepresentable(
                        calendar: calendar,
                        visibleDateRange: visibleDateRange,
                        monthsLayout: monthsLayout,
                        dataDependency: selectedDate,
                        proxy: calendarViewProxy)
                    .interMonthSpacing(0)
                    .verticalDayMargin(UIScreen.main.bounds.height * 0.064)
                    .horizontalDayMargin(0)
                    .dayOfWeekAspectRatio(0.5)
                    .dayOfWeekHeaders { _, weekdayIndex in
                        Text(daysOfWeek[weekdayIndex])
                            .font(.system(size: UIScreen.main.bounds.width * 0.03))
                            .padding(.bottom, -100)
                    }
                    .monthHeaders { _ in
                        Text("")
                    }
                    .days { day in
                        CalendarDayView(dayNumber: day.day, isSelected: isDaySelected(day))
                    }
                    .dayItemProvider { day in
                        if calendar.dateComponents([.year, .month, .day], from: calendar.date(from: day.components)!) ==
                            calendar.dateComponents([.year, .month, .day], from: weekCalendarManager.currentDate) {
                            ZStack(alignment: .center) {
                                Button(action: {
                                    if oneYearAgo! < calendar.date(from: day.components)! || entitlementManager.hasPro {
                                        updateWeekCalendar(withDate: calendar.date(from: day.components)!)
                                    } else {
                                        showPremium = true
                                    }
                                }, label: {
                                    if !showEmoji {
                                        CalendarEventItem(
                                            items: getCalendarItem(date: calendar.date(from: day.components)!),
                                            circleColor: .primary,
                                            numberColor: Color("todayFontColor"),
                                            day: day
                                        )
                                    } else {
                                        FulfillmentFace(
                                            items: getDateItem(date: calendar.date(from: day.components)!),
                                            circleColor: .primary,
                                            numberColor: Color("todayFontColor"),
                                            day: day
                                        )
                                    }
                                })
                            }.calendarItemModel
                        } else if calendar.date(from: day.components) == calendar.date(
                            from: DateComponents(year: year, month: month, day: nowDay)
                        )! {
                            Button(action: {
                                if oneYearAgo! < calendar.date(from: day.components)! || entitlementManager.hasPro {
                                    updateWeekCalendar(withDate: calendar.date(from: day.components)!)
                                } else {
                                    showPremium = true
                                }
                            }, label: {
                                if !showEmoji {
                                    CalendarEventItem(
                                        items: getCalendarItem(date: calendar.date(from: day.components)!),
                                        circleColor: Color(UIColor.todayBackground),
                                        numberColor: Color("todayFontColor"), day: day
                                    )
                                } else {
                                    FulfillmentFace(
                                        items: getDateItem(date: calendar.date(from: day.components)!),
                                        circleColor: Color(UIColor.todayBackground),
                                        numberColor: Color("todayFontColor"),
                                        day: day
                                    )
                                }
                            })
                            .calendarItemModel
                        } else {
                            Button(action: {
                                if oneYearAgo! < calendar.date(from: day.components)! || entitlementManager.hasPro {
                                    updateWeekCalendar(withDate: calendar.date(from: day.components)!)
                                } else {
                                    showPremium = true
                                }
                                print(calendar.date(from: day.components)!)
                            }, label: {
                                if !showEmoji {
                                    CalendarEventItem(
                                        items: getCalendarItem(date: calendar.date(from: day.components)!),
                                        circleColor: .clear,
                                        numberColor: .primary,
                                        day: day
                                    )
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            monthTitle = dateFormatter.string(
                                                from: calendar.date(from: day.components)!
                                            )
                                        }
                                    }
                                } else {
                                    FulfillmentFace(
                                        items: getDateItem(date: calendar.date(from: day.components)!),
                                        circleColor: .clear,
                                        numberColor: .primary,
                                        day: day
                                    )
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            monthTitle = dateFormatter.string(
                                                from: calendar.date(from: day.components)!
                                            )
                                        }
                                    }
                                }
                            })
                            .calendarItemModel
                        }
                    }
                    .onAppear {
                        calendarViewProxy.scrollToMonth(
                            containing: weekCalendarManager.currentDate,
                            scrollPosition: .centered,
                            animated: false
                        )
                    }
                    .frame(maxWidth: abs(.infinity))
                    CalendarHeader(
                        year: year,
                        month: month,
                        nowDay: nowDay,
                        calendar: calendar,
                        calendarViewProxy: calendarViewProxy,
                        monthTitle: $monthTitle,
                        showSearch: $showSearch,
                        showCalendarTypeMenu: $showCalendarTypeMenu,
                        showDatePicker: $showDatePicker,
                        showEmoji: $showEmoji)
                }
                .onAppear {
                    monthTitle = dateFormatter.string(from: Date())
                }
                .sheet(isPresented: $showCalendarTypeMenu) {
                    TagMenuView()
                }
                .sheet(isPresented: $showSearch) {
                    SearchView()
                }
                .fullScreenCover(isPresented: $showPremium, onDismiss: {
                    showPremium = false
                }, content: {
                    PremiumView()
                })
                .sheet(isPresented: $showDatePicker) {
                    DatePickerView(
                        calendarViewProxy: calendarViewProxy,
                        calendar: calendar,
                        visibleDateRange: visibleDateRange,
                        showDatePicker: $showDatePicker
                    )
                        .presentationDetents([.height(!entitlementManager.hasPro ? 340 : 265)])
                }
                .onChange(of: showCalendarTypeMenu) { newValue in
                    if !newValue {
                        createDate = UUID()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

extension CalendarMainView {
    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UIToolbar.appearance().barTintColor = .systemBackground
        UIToolbar.appearance().layer.borderWidth = 1
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        UIToolbar.appearance().isTranslucent = true
        }
    private func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        let predicate2 = NSPredicate(format: "tag.show == true")
        calendarItem.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        return calendarItem
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
    private func isDaySelected(_ day: DayComponents) -> Bool {
        if let selectedDayRange {
            return day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
        } else {
            return false
        }
    }
    private func updateWeekCalendar(withDate date: Date) {
        weekCalendarManager.currentDate = date
        weekCalendarManager.initWeeklyCalendar()
        showCalendar = false
    }
}
