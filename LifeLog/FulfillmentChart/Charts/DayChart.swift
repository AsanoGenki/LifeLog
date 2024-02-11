//
//  DayChart.swift
//  LifeLog
//
//  Created by Genki on 1/19/24.
//

import SwiftUI
import Charts

struct DayChart: View {
    @Binding var displayDate: Date
    @FetchRequest(sortDescriptors: []) var calendarItems: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var dateItems: FetchedResults<DateItem>

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("AVERAGE")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .fontWeight(.semibold)
                    HStack(alignment: .bottom) {
                        if let adequancy = getDateItem(date: displayDate)?.first?.adequancy {
                            if adequancy > 0 {
                                Text("\(adequancy)")
                                    .font(.system(size: 32, design: .rounded).bold())
                                    .foregroundColor(.primary) +
                                Text(" points")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .fontWeight(.semibold)
                            } else {
                                Text("No Data")
                                    .font(.system(size: 32, design: .rounded).bold())
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Text("No Data")
                                .font(.system(size: 32, design: .rounded).bold())
                                .foregroundColor(.primary)
                        }
                    }.frame(height: 24)
                    Text(weekDayToYear(displayDate))
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            Chart {
                ForEach(generateChartItems(for: displayDate)) { item in
                    if item.fulfillment > 0 {
                        LineMark(
                            x: .value("Category", item.date),
                            y: .value("Value", item.fulfillment)
                        )
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [.cyan, .green, .yellow],
                                        startPoint: .bottom, endPoint: .top
                                    )
                                )
                                .lineStyle(StrokeStyle(lineWidth: 4))
                                .alignsMarkStylesWithPlotArea()
                        AreaMark(
                            x: .value("Category", item.date),
                            y: .value("Value", item.fulfillment)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.cyan, .green, .yellow],
                                startPoint: .bottom, endPoint: .top
                            )
                            .opacity(0.5)
                        )
                        .alignsMarkStylesWithPlotArea()
                    }
                        PointMark(
                            x: .value("Category", item.date),
                            y: .value("Value", item.fulfillment)
                        )
                        .symbol {
                            Circle()
                                .foregroundStyle(.clear)
                                .frame(width: 14, height: 14)
                        }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .chartYScale(domain: 0 ... 100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 7)
    }
    private func getDateItem(date: Date) -> FetchedResults<DateItem>? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let predicate = NSPredicate(format: "(%@ <= date) AND (date <= %@)", targetDate as NSDate, targetDate as NSDate)
        dateItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return dateItems
    }
    private func calculateFulfillment(dates: [Date]) -> Int {
        var fulfillment = 0
        var itemCount = 0
        for date in dates {
            if let itemFulfillment = getDateItem(date: date)?.first {
                fulfillment += Int(itemFulfillment.adequancy)
                itemCount += 1
            }
        }
        if itemCount != 0 {
            fulfillment /= itemCount
        }
        return fulfillment
    }
    private func generateChartItems(for date: Date) -> [DayChartItem] {
        var result: [DayChartItem] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: date)
        let firstCurrentDate = calendar.date(byAdding: .hour, value: 2, to: currentDate)!
        currentDate = calendar.date(byAdding: .hour, value: 6, to: currentDate)!
        result.append(DayChartItem(fulfillment: 0, date: currentDate))
        while currentDate <= calendar.date(byAdding: .day, value: 1, to: firstCurrentDate)! {
            let nextCurrentDate = calendar.date(byAdding: .minute, value: 5, to: currentDate)!
            let predicate = NSPredicate(format: "(%@ >= startDate) AND (endDate >= %@)",
                                        currentDate as NSDate, nextCurrentDate as NSDate)
            calendarItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
            let adequancySum = calendarItems.reduce(0) { $0 + Int($1.adequancy) }
            var averageFulfillment = 0
            if calendarItems.count != 0 {
                averageFulfillment = Int(Double(adequancySum) / Double(calendarItems.count))
            }
            result.append(DayChartItem(fulfillment: averageFulfillment, date: currentDate))
            currentDate = nextCurrentDate
        }
        return result
    }
}

struct DayChartItem: Identifiable {
    var id = UUID()
    var fulfillment: Int
    var date: Date
}
