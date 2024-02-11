//
//  WeeklyChart.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import Charts
import CoreData
import Algorithms

struct WeeklyChart: View {
    let dates: [Date]
    @Binding var displayDate: Date
    @FetchRequest(sortDescriptors: []) var dateItems: FetchedResults<DateItem>
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
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("AVERAGE")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .fontWeight(.semibold)
                    HStack(alignment: .bottom) {
                        if calculateFulfillment(dates: dates) > 0 {
                            Text("\(calculateFulfillment(dates: dates))")
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
                    }.frame(height: 24)
                    Text(datesToString(displayDate: displayDate))
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            Chart {
                ForEach(dates.indexed(), id: \.element) { index, date in
                    let item = getDateItem(date: date)
                    LineMark(
                        x: .value("Category", daysOfWeek[index]),
                        y: .value("Value",
                                  (item?.first?.adequancy == nil ||
                                   item?.first?.adequancy == -1 ?
                                   0 : item?.first?.adequancy)!)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.gray, .cyan, .green, .yellow],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .alignsMarkStylesWithPlotArea()
                    if item?.first?.adequancy != nil && item?.first?.adequancy != -1 {
                        PointMark(
                            x: .value("Category", daysOfWeek[index]),
                            y: .value("Value", item?.first?.adequancy ?? 0)
                        )
                        .symbol {
                            returnFace(adequancy: Int(item?.first?.adequancy ?? 0))
                                .resizable()
                                .frame(width: 18, height: 18)
                        }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .chartYScale(domain: 0 ... 100)
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
}
