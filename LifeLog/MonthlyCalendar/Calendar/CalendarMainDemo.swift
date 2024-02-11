//
//  CalendarMainDemo.swift
//  LifeLog
//
//  Created by Genki on 12/30/23.
//

import HorizonCalendar
import SwiftUI
import EventKit

struct TabViews: View {
    enum Tab {
        case calendar
        case dialy
        case timerList
        case chart
    }
    @State private var selection: Tab = .calendar
    var body: some View {
        TabView(selection: $selection) {
            CalendarMainDemo(calendar: Calendar.current, monthsLayout: .horizontal)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Home")
                }.tag(Tab.calendar)
            CalendarMainDemo(calendar: Calendar.current, monthsLayout: .horizontal)
                .tabItem {
                    Image(systemName: "book.pages")
                    Text("Diary")
                }.tag(Tab.dialy)
            CalendarMainDemo(calendar: Calendar.current, monthsLayout: .horizontal)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Timer")
                }.tag(Tab.timerList)
            CalendarMainDemo(calendar: Calendar.current, monthsLayout: .horizontal)
                .tabItem {
                    Image(systemName: "chart.dots.scatter")
                    Text("insights")
                }.tag(Tab.chart)
        }.accentColor(Color("iconColor"))
    }
}
struct CalendarMainDemo: View {

    let year = Calendar.current.component(.year, from: Date())
    let month = Calendar.current.component(.month, from: Date())
    let nowDay = Calendar.current.component(.day, from: Date())
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
        // ナビゲーションバーの外観をカスタマイズ
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
    @State private var selectedDate: DayComponents?
    @State var monthTitle = ""
    @State var showEventDetail = false
    @State var showTimerList = false
    @State var showEventEdit = false
    @State var createDate = UUID()
    @State var showSettings = false
    @State var showCalendarTypeMenu = false
    @State var showSearch = false
    @AppStorage("calendarSelectedDate") var calendarSelectedDate = Date()
    @State var title = ""
    @State var startDate = Date()
    @State var endDate = Date()
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
        if Locale.current.language.languageCode?.identifier == "ja" {
            dateFormatter.dateFormat = "yyyy年MMM"
        } else {
            dateFormatter.dateFormat = "MMM yyyy"
        }
        return dateFormatter
    }()
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @State var showPremium = false
    @State var showDatePicker = false
    @State var showEmoji = false
    @AppStorage("fromNotification") var fromNotification = false
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
                            if day == selectedDate {
                                ZStack(alignment: .center) {
                                    Button {
                                        if oneYearAgo! < calendar.date(from: day.components)! ||
                                            entitlementManager.hasPro {
                                            print(calendarSelectedDate)
                                            showEventDetail.toggle()
                                        } else {
                                            showPremium = true
                                        }
                                    } label: {
                                        CalendarItemDemo(circleColor: .primary,
                                                         numberColor: Color("todayFontColor"),
                                                         day: day)
                                    }
                                }.calendarItemModel
                            } else if calendar.date(from: day.components) == calendar.date(
                                from: DateComponents(year: year, month: month, day: nowDay))! {
                                Button {
                                    selectedDate = day
                                    calendarSelectedDate = calendar.date(from: day.components)!
                                } label: {
                                    CalendarItemDemo(circleColor: Color(UIColor.todayBackground),
                                                     numberColor: Color("todayFontColor"),
                                                     day: day)
                                }.calendarItemModel
                            } else {
                                Button {
                                    selectedDate = day
                                    calendarSelectedDate = calendar.date(from: day.components)!
                                } label: {
                                    CalendarItemDemo(circleColor: .clear, numberColor: .primary, day: day)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                monthTitle = dateFormatter.string(
                                                    from: calendar.date(
                                                        from: day.components)!
                                                )
                                            }
                                        }
                                }
                                .calendarItemModel
                            }
                        }
                        .onAppear {
                            calendarViewProxy.scrollToMonth(
                                containing: Date(),
                                scrollPosition: .centered,
                                animated: false)
                        }
                        .frame(maxWidth: abs(.infinity))
                        Spacer()
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
                        showEmoji: $showEmoji
                    )
                }
                .onAppear {
                    if fromNotification == true {
                        showEventEdit = true
                        fromNotification = false
                    }
                    monthTitle = dateFormatter.string(from: Date())
                }
                .onChange(of: fromNotification) { _ in
                    if fromNotification == true {
                        showEventEdit = true
                        fromNotification = false
                    }
                }
                .sheet(isPresented: $showEventDetail) {
                    EventDetailView(date: $calendarSelectedDate)
                }
                .sheet(isPresented: $showEventEdit) {
                    NavigationStack {
                        CreateEventView(title: $title,
                                        startDate: $startDate,
                                        endDate: $endDate,
                                        createDate: $createDate)
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingView()
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
                    DatePickerView(calendarViewProxy: calendarViewProxy,
                                   calendar: calendar,
                                   visibleDateRange: visibleDateRange,
                                   showDatePicker: $showDatePicker)
                        .presentationDetents([.fraction(!entitlementManager.hasPro ? 0.45 : 0.35)])
                }
                .onChange(of: showCalendarTypeMenu) { newValue in
                    if !newValue {
                        createDate = UUID()
                    }
                }
                .onChange(of: showEventDetail) { newValue in
                    if !newValue {
                        createDate = UUID()
                    }
                }
                .onChange(of: showTimerList) { newValue in
                    if !newValue {
                        createDate = UUID()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>
    private let monthDateFormatter: DateFormatter
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    @State private var selectedDayRange: DayComponentsRange?
    @State private var selectedDayRangeAtStartOfDrag: DayComponentsRange?
    private func isDaySelected(_ day: DayComponents) -> Bool {
        if let selectedDayRange {
            return day == selectedDayRange.lowerBound || day == selectedDayRange.upperBound
        } else {
            return false
        }
    }
}

struct CalendarMainDemo_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMainDemo(calendar: Calendar.current, monthsLayout: .horizontal)
    }
}
