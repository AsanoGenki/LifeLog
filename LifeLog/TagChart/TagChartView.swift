//
//  TagChart.swift
//  LifeLog
//
//  Created by Genki on 1/20/24.
//

import SwiftUI
import CoreData
struct TagChartView: View {
    @State private var showPremium = false
    @State private var showFilterTagView = false
    @AppStorage("pieChartDate") var pieChartDate = Date()
    @FetchRequest(sortDescriptors: []) private var calendarItem: FetchedResults<CalendarItem>
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @ObservedObject var viewModel: PieChartViewModel = PieChartViewModel()
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ScrollView {
                        VStack {
                            Picker("", selection: $viewModel.model.pieChartDateTab) {
                                ForEach(DateTab.allCases.dropLast(), id: \.self) { dateTab in
                                    Text(LocalizedStringKey(dateTab.text))
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .onChange(of: viewModel.chartDateTab) { _ in
                                if !entitlementManager.hasPro && viewModel.chartDateTab != .day {
                                    showPremium = true
                                }
                            }
                            if viewModel.chartDateTab == .day || entitlementManager.hasPro {
                                VStack {
                                    PieChart(
                                        geometry: geometry,
                                        viewModel: viewModel
                                    )
                                    HStack(spacing: 20) {
                                        Button {
                                            pieChartDate = Date()
                                            viewModel.changeSwipeDirection(inputSwipeDirection: .none)
                                        } label: {
                                            HStack {
                                                Image(systemName: "arrow.uturn.right")
                                                    .font(.system(size: 12))
                                                Text("Today")
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .opacity(viewModel.swipeDirection != .left ? 0 : 1)
                                        .foregroundStyle(.primary)
                                        HStack(spacing: 12) {
                                            Button {
                                                viewModel.handleSwipeLeft()
                                            } label: {
                                                Image(systemName: "arrowtriangle.left.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color("iconColor"))
                                            }
                                            if viewModel.chartDateTab == .day {
                                                Text(weekDayToYear(pieChartDate))
                                                    .font(.system(size: 14))
                                            } else if viewModel.chartDateTab == .week {
                                                Text(datesToString(displayDate: pieChartDate))
                                                    .font(.system(size: 14))
                                            } else if viewModel.chartDateTab == .month {
                                                Text(monthToYear(date: pieChartDate))
                                                    .font(.system(size: 14))
                                            }
                                            Button {
                                                viewModel.handleSwipeRight()
                                            } label: {
                                                Image(systemName: "arrowtriangle.right.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color("iconColor"))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        Button {
                                            pieChartDate = Date()
                                            viewModel.changeSwipeDirection(inputSwipeDirection: .none)
                                        } label: {
                                            HStack {
                                                Text("Today")
                                                    .font(.system(size: 12))
                                                Image(systemName: "arrow.uturn.left")
                                                    .font(.system(size: 12))
                                            }
                                        }.opacity(viewModel.swipeDirection != .right ? 0 : 1)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)
                                    if viewModel.chartDateTab == .day {
                                        TagDataView(
                                            items: getTotalDurationsForAllCalendarTypes(
                                                date: pieChartDate
                                            )
                                        )
                                            .padding(.top)
                                    } else if viewModel.chartDateTab == .week {
                                        TagDataView(items: weeklyGetTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate))
                                            .padding(.top)
                                    } else {
                                        TagDataView(items: getMonthlyTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate))
                                            .padding(.top)
                                    }
                                    if viewModel.chartDateTab == .day || viewModel.chartDateTab == .week ||
                                        entitlementManager.hasPro {
                                            PieChartEventList(
                                                showFilterTagView: $showFilterTagView,
                                                pieChartDate: $pieChartDate,
                                                viewModel: viewModel
                                            )
                                    }
                                }
                            } else {
                                ZStack {
                                    TagChartDemo(geometry: geometry)
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("whiteBlack").opacity(0.5),
                                            Color("whiteBlack").opacity(0.8),
                                            Color("whiteBlack").opacity(1.0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    HStack(spacing: 3) {
                                        Image(systemName: "lock")
                                        Text("Unlock with Premium")
                                    }
                                    .font(.headline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    .background(Color("buttonColor").cornerRadius(100))
                                    .foregroundColor(Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)))
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 0))
                                .onTapGesture {
                                    showPremium = true
                                }
                            }
                            Rectangle()
                                .frame(width: 1, height: 60)
                                .foregroundStyle(.clear)
                        }
                        .foregroundColor(Color.primary)
                    }
                    VStack {
                        Spacer()
                        if !entitlementManager.hasPro {
                            if networkMonitor.isConnected {
                                BannerAdView(adUnit: .mainView, adFormat: .adaptiveBanner)
                            } else {
                                PremiumAdsView()
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            viewModel.handleGesture(value: value)
                        }
                )
                .navigationTitle("Chart")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showPremium) {
                    PremiumView()
                }
                .sheet(isPresented: $showFilterTagView) {
                    FilterTagView(viewModel: viewModel)
                }
            }
        }
    }
}

extension TagChartView {
    func getTotalDurationsForAllCalendarTypes(date: Date) -> [CalendarTypeSum] {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!

        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        var totalDurationsByType = [EventTag: TimeInterval]()
        for calendarItem in calendarItem {
            guard let startDate = calendarItem.startDate,
                  let endDate = calendarItem.endDate,
                  let calendarType = calendarItem.tag else {
                continue
            }
            let duration = endDate.timeIntervalSince(startDate)
            totalDurationsByType[calendarType, default: 0.0] += duration
        }
        var calendarTypeSums: [CalendarTypeSum] = totalDurationsByType.map { (calendarType, totalDuration) in
            return CalendarTypeSum(tag: calendarType, totalDuration: totalDuration)
        }
        calendarTypeSums.sort { (lhs, rhs) in
                if lhs.totalDuration > rhs.totalDuration {
                    return true
                } else if lhs.totalDuration == rhs.totalDuration {
                    return lhs.tag.name! < rhs.tag.name!
                } else {
                    return false
                }
            }
        return calendarTypeSums
    }
    func weeklyGetTotalDurationsForAllCalendarTypes(
        date: Date) -> [CalendarTypeSum] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let sunday = calendar.date(from: components)!
        let saturday = calendar.date(byAdding: .day, value: 6, to: sunday)!

        let startDate = calendar.startOfDay(for: sunday)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: saturday)!

        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        var totalDurationsByType = [EventTag: TimeInterval]()

        for calendarItem in calendarItem {
            guard let startDate = calendarItem.startDate,
                  let endDate = calendarItem.endDate,
                  let calendarType = calendarItem.tag else {
                continue
            }
            let duration = endDate.timeIntervalSince(startDate)
            totalDurationsByType[calendarType, default: 0.0] += duration
        }
        var calendarTypeSums: [CalendarTypeSum] = totalDurationsByType.map { (calendarType, totalDuration) in
            return CalendarTypeSum(tag: calendarType, totalDuration: totalDuration)
        }
        calendarTypeSums.sort { (lhs, rhs) in
                if lhs.totalDuration > rhs.totalDuration {
                    return true
                } else if lhs.totalDuration == rhs.totalDuration {
                    return lhs.tag.name! < rhs.tag.name!
                } else {
                    return false
                }
            }

        return calendarTypeSums
    }
    func getMonthlyTotalDurationsForAllCalendarTypes(
        date: Date) -> [CalendarTypeSum] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        var totalDurationsByType = [EventTag: TimeInterval]()
        for calendarItem in calendarItem {
            guard let startDate = calendarItem.startDate,
                  let endDate = calendarItem.endDate,
                  let calendarType = calendarItem.tag else {
                continue
            }
            let duration = endDate.timeIntervalSince(startDate)
            totalDurationsByType[calendarType, default: 0.0] += duration
        }
        var calendarTypeSums: [CalendarTypeSum] = totalDurationsByType.map { (calendarType, totalDuration) in
            return CalendarTypeSum(tag: calendarType, totalDuration: totalDuration)
        }
        calendarTypeSums.sort { (lhs, rhs) in
                if lhs.totalDuration > rhs.totalDuration {
                    return true
                } else if lhs.totalDuration == rhs.totalDuration {
                    return lhs.tag.name! < rhs.tag.name!
                } else {
                    return false
                }
            }
        return calendarTypeSums
    }
}
