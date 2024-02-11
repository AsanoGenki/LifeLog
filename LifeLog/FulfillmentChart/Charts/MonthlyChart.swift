//
//  MonthlyChart.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import Charts

struct MonthlyChart: View {
    let dates: [Date]
//    @Binding var selectedElement: Date?
    @Binding var displayDate: Date
    @FetchRequest(sortDescriptors: []) var dateItems: FetchedResults<DateItem>
    @ObservedObject var viewModel: ChartViewModel
    var body: some View {
        VStack(alignment: .leading) {
            if let selectedElement = viewModel.selectedElement {
                HStack {
                    VStack(alignment: .leading) {
                        Text("AVERAGE")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .fontWeight(.semibold)
                        if getDateItem(date: selectedElement)?.first?.adequancy ?? 0 > 0 {
                            HStack {
                                Text("\(getDateItem(date: selectedElement)?.first?.adequancy ?? 0)")
                                    .font(.system(size: 32, design: .rounded).bold())
                                    .foregroundColor(.primary) +
                                Text(" points")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .fontWeight(.semibold)
                            }.frame(height: 24)
                        } else {
                            Text("-")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .frame(height: 24)
                        }
                        Text(dayToYear(date: selectedElement))
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }} else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("AVERAGE")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .fontWeight(.semibold)
                                HStack(alignment: .bottom) {
                                    if calculateFulfillment(dates: dates) > 0 {
                                    Text(String(calculateFulfillment(dates: dates)))
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
                            Text(monthToYear(date: displayDate))
                                .font(.system(size: 16, design: .rounded))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
            }
            Chart {
                ForEach(dates.indexed(), id: \.element) { _, date in
                    let fulfillment = Int(getDateItem(date: date)?.first?.adequancy ?? 0)
                    if fulfillment > 0 {
                        LineMark(
                            x: .value("Category", date),
                            y: .value("Value", fulfillment)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.gray, .cyan, .green, .yellow],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .alignsMarkStylesWithPlotArea()
                        AreaMark(
                            x: .value("Category", date),
                            y: .value("Value", fulfillment)
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
                        x: .value("Category", date),
                        y: .value("Value", fulfillment)
                    )
                    .foregroundStyle(returnColor(fulfillment: fulfillment))
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let element = findElement(location: value.location,
                                                               proxy: proxy,
                                                               geometry: geo, displayDate: displayDate)
                                    if viewModel.selectedElement == element {
                                        viewModel.model.selectedElement = nil
                                    } else {
                                        viewModel.model.selectedElement = element
                                    }
                                }
                                .exclusively(before: DragGesture()
                                    .onChanged { value in
                                        viewModel.model.selectedElement = findElement(
                                            location: value.location,
                                            proxy: proxy, geometry: geo,
                                            displayDate: displayDate)
                                    })
                        )
                }
            }
            .chartBackground { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        if let selectedElement = viewModel.selectedElement {
                            let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement)!
                            let startPositionX = proxy.position(forX: dateInterval.start) ?? 0
                            let midStartPositionX = startPositionX + geo[proxy.plotAreaFrame].origin.x
                            let lineHeight = geo[proxy.plotAreaFrame].maxY
                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: 2, height: lineHeight)
                                .position(x: midStartPositionX, y: lineHeight / 2)
                        }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .chartYScale(domain: 0 ... 100)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .padding(.leading, 14)
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
