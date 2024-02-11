//
//  PieChart.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

struct PieChart: View {
    @AppStorage("pieChartDate") var pieChartDate = Date()
    @FetchRequest(sortDescriptors: []) private var calendarItem: FetchedResults<CalendarItem>
    let geometry: GeometryProxy
    var widthFraction: CGFloat = 0.75
    var innerRadiusFraction: CGFloat = 0.60
    @ObservedObject var viewModel: PieChartViewModel
    var totalDurations: [CalendarTypeSum] {
        if viewModel.chartDateTab == .day {
               return getTotalDurationsForAllCalendarTypes(date: pieChartDate)
           } else if viewModel.chartDateTab == .week {
               return weeklyGetTotalDurationsForAllCalendarTypes(date: pieChartDate)
           } else {
               return getMonthlyTotalDurationsForAllCalendarTypes(date: pieChartDate)
           }
       }
    var body: some View {
            ZStack {
                if slices().count != 0 {
                    ForEach(Array(slices().enumerated()), id: \.element) { index, item in
                        if slices().count != 0 {
                            PieSlice(pieSliceData: item)
                                .onTapGesture {
                                    if viewModel.activePieChartIndex != index {
                                        viewModel.changeActivePieChartIndex(index: index)
                                    } else {
                                        viewModel.changeActivePieChartIndex(index: -1)
                                    }
                                }
                                .scaleEffect(viewModel.activePieChartIndex == index ? 1.03 : 1)
                        }
                    }
                    .frame(width: geometry.size.width,
                           height: widthFraction * geometry.size.width)
                    Circle()
                        .fill(Color("whiteBlack"))
                        .frame(width: widthFraction * geometry.size.width
                               * innerRadiusFraction,
                               height: widthFraction * geometry.size.width
                               * innerRadiusFraction)
                } else {
                    Circle()
                        .fill(Color(UIColor.systemFill))
                        .frame(width: geometry.size.width,
                               height: widthFraction * geometry.size.width)
                    Circle()
                        .fill(Color("whiteBlack"))
                        .frame(width: widthFraction * geometry.size.width
                               * innerRadiusFraction,
                               height: widthFraction * geometry.size.width
                               * innerRadiusFraction)
                }
                VStack {
                    if slices().count != 0 {
                        if viewModel.chartDateTab == .day {
                            Text((viewModel.activePieChartIndex == -1 ? "Total" :
                                    calendarTypeToCalendarTypeSum(
                                        from: getTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate)
                                    )[viewModel.activePieChartIndex].name) ?? "")
                                .font(.title2)
                            if viewModel.activePieChartIndex == -1 {
                                Text(formattedTimeInterval(
                                    timeInterval: getTotalDurationTimeInterval(
                                        calendarTypeSums:
                                            getTotalDurationsForAllCalendarTypes(
                                                date: pieChartDate))))
                                    .font(.title2)
                            } else {
                                Text(formattedTimeInterval(
                                    timeInterval: getTotalDurationsForAllCalendarTypes(
                                        date: pieChartDate)[viewModel.activePieChartIndex].totalDuration))
                                    .font(.title2)
                            }
                        } else if viewModel.chartDateTab == .week {
                            Text((viewModel.activePieChartIndex == -1 ? "Total" :
                                    calendarTypeToCalendarTypeSum(
                                        from: weeklyGetTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate)
                                    )[viewModel.activePieChartIndex].name) ?? "")
                                .font(.title2)
                            if viewModel.activePieChartIndex == -1 {
                                Text(formattedTimeInterval(
                                    timeInterval: getTotalDurationTimeInterval(
                                        calendarTypeSums:
                                            weeklyGetTotalDurationsForAllCalendarTypes(
                                                date: pieChartDate))))
                                    .font(.title2)
                            } else {
                                Text(
                                    formattedTimeInterval(
                                        timeInterval:
                                            weeklyGetTotalDurationsForAllCalendarTypes(
                                                date: pieChartDate)[viewModel.activePieChartIndex]
                                            .totalDuration))
                                    .font(.title2)
                            }
                        } else {
                            Text((viewModel.activePieChartIndex == -1 ? "Total" :
                                    calendarTypeToCalendarTypeSum(
                                        from: getMonthlyTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate)
                                    )[viewModel.activePieChartIndex].name) ?? "")
                                .font(.title2)
                            if viewModel.activePieChartIndex == -1 {
                                Text(formattedTimeInterval(
                                    timeInterval: getTotalDurationTimeInterval(
                                        calendarTypeSums:
                                            getMonthlyTotalDurationsForAllCalendarTypes(
                                                date: pieChartDate))))
                                    .font(.title2)
                            } else {
                                Text(formattedTimeInterval(
                                    timeInterval:
                                        getMonthlyTotalDurationsForAllCalendarTypes(
                                            date: pieChartDate)[viewModel.activePieChartIndex].totalDuration))
                                    .font(.title2)
                            }
                        }
                    } else {
                        Text("No Data")
                            .font(.title2)
                    }
                }
            }
            .padding(.vertical)
    }
}

extension PieChart {
    private func slices() -> [PieSliceData] {
            let sum = calendarTypeSumToDouble(from: totalDurations).reduce(0, +)
            var endDeg: Double = 0
            var tempSlices: [PieSliceData] = []

            for (index, value) in totalDurations.enumerated() {
                let tag = calendarTypeToCalendarTypeSum(from: totalDurations)[index]
                let degrees: Double = calendarTypeSumToDouble(from: totalDurations)[index] * 360 / sum
                tempSlices.append(PieSliceData(
                    startAngle: Angle(degrees: endDeg),
                    endAngle: Angle(degrees: endDeg + degrees),
                    text: tag.name ?? "",
                    color: convertDataToColor(data: tag.color!) ??
                        .blue, percentage: value.totalDuration * 100 / sum))
                endDeg += degrees
            }

            return tempSlices
        }
    private func getTotalDurationTimeInterval(calendarTypeSums: [CalendarTypeSum]) -> TimeInterval {
        let totalDuration = calendarTypeSums.reduce(0) { $0 + $1.totalDuration }
        return totalDuration
    }
    private func calendarTypeSumToDouble(from calendarTypeSums: [CalendarTypeSum]) -> [Double] {
            let sortedDurations: [Double] = calendarTypeSums.map { $0.totalDuration }
            return sortedDurations
        }
    private func calendarTypeToCalendarTypeSum(from calendarTypeSums: [CalendarTypeSum]) -> [EventTag] {
            let sortedCalendarTypes: [EventTag] = calendarTypeSums.map { $0.tag }
            return sortedCalendarTypes
        }
    private func getTotalDurationsForAllCalendarTypes(date: Date) -> [CalendarTypeSum] {
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
    private func weeklyGetTotalDurationsForAllCalendarTypes(
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
    private func getMonthlyTotalDurationsForAllCalendarTypes(
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
