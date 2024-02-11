//
//  ChartDataMethod.swift
//  LifeLog
//
//  Created by Genki on 11/17/23.
//

import SwiftUI
import Charts

struct DataPoint: Identifiable {
    var id = UUID()
    let title: String
    let value: Double
    let image: Image
}
func returnFace(adequancy: Int) -> Image {
    if adequancy < 20 {
        return Image("badFace")
    } else if 20 <= adequancy && adequancy < 40 {
        return Image("notGreateFace")
    } else if 40 <= adequancy && adequancy < 60 {
        return Image("sosoFace")
    } else if 60 <= adequancy && adequancy < 80 {
        return Image("neutralFace")
    } else {
        return Image("smileFace")
    }
}
func getThisWeekDates(displayDate: Date) -> [Date] {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: displayDate)
    let startOfWeek = calendar.date(byAdding: .day, value: 1-weekday, to: displayDate)!
    return (0...6).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
}

func getThisMonthDates(displayDate: Date) -> [Date] {
    let calendar = Calendar.current
    let range = calendar.range(of: .day, in: .month, for: displayDate)!
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayDate))!
    return (0..<range.count).map { calendar.date(byAdding: .day, value: $0, to: startOfMonth)! }
}

func getThis6MonthDates(displayDate: Date) -> [Date] {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: displayDate)
    let month = calendar.component(.month, from: displayDate)
    let startMonth: Int
    let endMonth: Int
    if month >= 1 && month <= 6 {
        startMonth = 1
        endMonth = 6
    } else {
        startMonth = 7
        endMonth = 12
    }
    let startDateComponents = DateComponents(year: year, month: startMonth, day: 1)
    let endDateComponents = DateComponents(
        year: year,
        month: endMonth,
        day: calendar.range(
            of: .day,
            in: .month,
            for: calendar.date(from: DateComponents(year: year, month: endMonth))!)!.count)
    let startDate = calendar.date(from: startDateComponents)!
    let endDate = calendar.date(from: endDateComponents)!
    let dates = sequence(first: startDate, next: { date in
        let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
        return nextDate <= endDate ? nextDate : nil
    })
    return Array(dates)
}

func getWeeklyDates(displayDate: Date) -> [[Date]] {
    let allDates = getThis6MonthDates(displayDate: displayDate)
    var weeklyDates: [[Date]] = []
    var week: [Date] = []
    for date in allDates {
        if week.count < 7 {
            week.append(date)
        } else {
            weeklyDates.append(week)
            week = [date]
        }
    }
    if !week.isEmpty {
        weeklyDates.append(week)
    }
    return weeklyDates
}
func dateRange(displayDate: Date) -> String {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month, .year], from: displayDate)
    guard let month = components.month, let year = components.year else {
        return "Invalid date"
    }
    if month >= 1 && month <= 6 {
        if Locale.current.language.languageCode?.identifier == "ja" {
            return "\(year)年 1月 〜 6月"
        } else {
            return "Jan - Jun, \(year)"
        }
    } else if month >= 7 && month <= 12 {
        if Locale.current.language.languageCode?.identifier == "ja" {
            return "\(year)年 7月 〜 12月"
        } else {
            return "Jul - Dec, \(year)"
        }
    } else {
        return "Invalid date"
    }
}

func datesToString(displayDate: Date) -> String {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: displayDate)
    let startOfWeek = calendar.date(byAdding: .day, value: 1-weekday, to: displayDate)!
    let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
    let dateFormatter = DateFormatter()
    let dateFormatter2 = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "yyyy年MMMd日"
        dateFormatter2.dateFormat = "d日"
    } else {
        dateFormatter.dateFormat = "MMM d"
        dateFormatter2.dateFormat = "d, yyyy"
    }
    let startOfWeekString = dateFormatter.string(from: startOfWeek)
    let endOfWeekString = dateFormatter2.string(from: endOfWeek)
    if Locale.current.language.languageCode?.identifier == "ja" {
        return "\(startOfWeekString) 〜 \(endOfWeekString)"
    } else {
        return "\(startOfWeekString) - \(endOfWeekString)"
    }
}

func weeklyDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "MMMd日"
    } else {
        dateFormatter.dateFormat = "MMM d"
    }
    let startDateString = dateFormatter.string(from: date)
    let endDate = Calendar.current.date(byAdding: .day, value: 6, to: date)!
    let endDateString = dateFormatter.string(from: endDate)
    return "\(startDateString) - \(endDateString)"
}

func findElement(
    location: CGPoint,
    proxy: ChartProxy,
    geometry: GeometryProxy,
    displayDate: Date) -> Date? {
    let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
    if let date = proxy.value(atX: relativeXPosition) as Date? {
        var minDistance: TimeInterval = .infinity
        var index: Int?
        for dataIndex in getThisMonthDates(displayDate: displayDate).indices {
            let nthDataDistance = getThisMonthDates(displayDate: displayDate)[dataIndex].distance(to: date)
            if abs(nthDataDistance) < minDistance {
                minDistance = abs(nthDataDistance)
                index = dataIndex
            }
        }
        if let index {
            return getThisMonthDates(displayDate: displayDate)[index]
        }
    }
    return nil
}

func find6MonthElement(
    location: CGPoint,
    proxy: ChartProxy,
    geometry: GeometryProxy,
    displayDate: Date) -> Date? {
    let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
    if let date = proxy.value(atX: relativeXPosition) as Date? {
        var minDistance: TimeInterval = .infinity
        var index: Int?
        let dates = getThis6MonthDates(displayDate: displayDate)
        let selectedDates = dates.enumerated().filter { index, _ in
            return index % 7 == 0
        }.map { $0.element }
        for dataIndex in selectedDates.indices {
            let nthDataDistance = selectedDates[dataIndex].distance(to: date)
            if abs(nthDataDistance) < minDistance {
                minDistance = abs(nthDataDistance)
                index = dataIndex
            }
        }
        if let index {
            return selectedDates[index]
        }
    }
    return nil
}

func returnColor(fulfillment: Int) -> Color {
    if fulfillment <= 0 {
        return .clear
    }
    if fulfillment < 20 {
        return .red
    } else if 20 <= fulfillment && fulfillment < 40 {
        return .purple
    } else if 40 <= fulfillment && fulfillment < 60 {
        return .cyan
    } else if 60 <= fulfillment && fulfillment < 80 {
        return Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
    } else {
        return .yellow
    }
}
