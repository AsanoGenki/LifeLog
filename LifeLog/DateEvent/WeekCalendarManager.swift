//
//  WeekStore.swift
//  LifeLog
//
//  Created by Genki on 1/17/24.
//

import Foundation

class WeekCalendarManager: ObservableObject {
    struct WeekValue: Identifiable {
        var id: Int
        var date: [Date]
    }
    @Published var allWeeks: [WeekValue] = []
    @Published var currentDate: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    @Published var currentIndex: Int = 0
    @Published var indexToUpdate: Int = 0
    @Published var currentWeek: [Date] = []
    @Published var nextWeek: [Date] = []
    @Published var previousWeek: [Date] = []
    @Published var snappedItem = 0.0
    @Published var draggingItem = 0.0
    init() {
        fetchCurrentWeek()
        fetchPreviousNextWeek()
        appendAll()
    }
    func appendAll() {
        var  newWeek = WeekValue(id: 0, date: currentWeek)
        allWeeks.append(newWeek)
        newWeek = WeekValue(id: 2, date: nextWeek)
        allWeeks.append(newWeek)
        newWeek = WeekValue(id: 1, date: previousWeek)
        allWeeks.append(newWeek)
    }
    func updateWeekDays(index: Int, direction: Int) {
        var value: Int = 0
        if index < currentIndex {
            value = 1
            if indexToUpdate ==  2 {
                indexToUpdate = 0
            } else {
                indexToUpdate += 1
            }
        } else {
            value = -1
            if indexToUpdate ==  0 {
                indexToUpdate = 2
            } else {
                indexToUpdate -= 1
            }
        }
        currentIndex = index
        addDatesForWeek(index: indexToUpdate, value: value)
    }
    func addDatesForWeek(index: Int, value: Int) {
        allWeeks[index].date.removeAll()
        var calendar = Calendar(identifier: .gregorian)
        let today = Calendar.current.date(byAdding: .day, value: (7 * value) - 1, to: self.currentDate)!
        calendar.firstWeekday = 7
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                allWeeks[index].date.append(weekday)
            }
        }
    }
    func isSelectDate(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDate, inSameDayAs: date)
    }
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: Date())
    }
    func dateToString(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    func fetchCurrentWeek() {
        currentWeek.removeAll()
        let today = currentDate
        var calendar = Calendar(identifier: .gregorian)
        var startOfWeek = Date()
        calendar.firstWeekday = 7
        if Calendar.current.component(.weekday, from: currentDate) != 7 {
            startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        } else {
            startOfWeek = calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: Calendar.current.date(
                        byAdding: .day, value: -1, to: today)!))!
        }
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                currentWeek.append(weekday)
            }
        }
        currentIndex = 0
        indexToUpdate = 0
    }
    func fetchPreviousNextWeek() {
        nextWeek.removeAll()
        let nextWeekToday = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 7
        let startOfWeekNext = calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: nextWeekToday))!
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeekNext) {
                nextWeek.append(weekday)
            }
        }
        previousWeek.removeAll()
        let previousWeekToday = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        let startOfWeekPrev = calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: previousWeekToday))!
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: startOfWeekPrev) {
                previousWeek.append(weekday)
            }
        }
    }
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(allWeeks.count))
    }
    func myXOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(allWeeks.count) * distance(item)
        return sin(angle) * 200
    }
    func goToday() {
        currentDate = Date()
        initWeeklyCalendar()
    }
    func initWeeklyCalendar() {
        fetchCurrentWeek()
        fetchPreviousNextWeek()
        allWeeks.removeAll()
        appendAll()
        draggingItem = 0
        snappedItem = 0
    }
}
