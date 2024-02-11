//
//  DemoChartView.swift
//  LifeLog
//
//  Created by Genki on 11/30/23.
//

import SwiftUI
import Charts

struct DemoChartView: View {
    let data = DemoEventData()
    let listType = ["Event", "Dialy"]
    @State private var selectListType = 0
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("AVERAGE")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .fontWeight(.semibold)
                        HStack(alignment: .bottom) {
                            Text("68")
                                .font(.system(size: 32, design: .rounded).bold())
                                .foregroundColor(.primary) +
                            Text(" points")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .fontWeight(.semibold)
                        }.frame(height: 24)
                        Text("Sep, 2022")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.top, 7)
                DemoChart()
                HStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Button {
                        } label: {
                            Image(systemName: "arrowtriangle.left.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color("iconColor"))
                        }
                        Text("September, 2022")
                            .font(.system(size: 14))
                        Button {
                        } label: {
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color("iconColor"))
                        }
                    }.frame(maxWidth: .infinity)
                }
                HStack(spacing: 20) {
                    Spacer()
                    Menu {
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "tag")
                            Text("All")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                    }
                    Menu {
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Recently")
                        }.font(.system(size: 12))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 6)
                VStack {
                    ForEach(data.demoEvents) { event in
                        HStack {
                            Rectangle()
                                .frame(width: 4, height: 34)
                                .cornerRadius(100)
                                .foregroundColor(event.color)
                            VStack(alignment: .leading) {
                                Text(event.title)
                                Text(eventItemDate(startDate: event.startDate, endDate: event.startDate))
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(UIColor.systemGray))
                            }
                            Spacer()
                            if Int(event.fullfilment) != -1 {
                                HStack {
                                    returnFace(adequancy: Int(event.fullfilment))
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("\(event.fullfilment)")
                                        .font(.system(size: 14))
                                }
                            } else {
                                HStack {
                                    Image("noFace")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("-")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Spacer()
            }
    }
}

#Preview {
    DemoChartView()
}

struct DemoChart: View {
    var body: some View {
            Chart {
                ForEach(createSeptember2022DateArray().indexed(), id: \.element) { _, date in
                    let value = Int.random(in: 45...85)
                    LineMark(
                        x: .value("Category", date),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(.gray)
                    AreaMark(
                        x: .value("Category", date),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.cyan, .green, .yellow],
                            startPoint: .bottom, endPoint: .top
                        )
                        .opacity(0.5)
                    )
                    .alignsMarkStylesWithPlotArea()
                    PointMark(
                        x: .value("Category", date),
                        y: .value("Value", value)
                    )
                    .foregroundStyle(returnColor(fulfillment: value))
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.25)
            .padding(.leading, 14)
            .padding(.top, 10)
    }
}

func createSeptember2022DateArray() -> [Date] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    let start = dateFormatter.date(from: "2022/09/01")!
    let end = dateFormatter.date(from: "2022/09/30")!
    var dateArray: [Date] = []
    var date = start
    while date <= end {
        dateArray.append(date)
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    return dateArray
}
struct DemoEvent: Identifiable {
    var id = UUID()
    let title: String
    let fullfilment: Int
    let startDate: Date
    let color: Color
}
struct DemoEventData {
    var dateFormatter: DateFormatter
    var demoEvents: [DemoEvent]

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        demoEvents = [
            DemoEvent(title: "Jogging", fullfilment: 85,
                      startDate: dateFormatter.date(from: "2022/09/01 07:00")!, color: .red),
            DemoEvent(title: "Reading", fullfilment: 90,
                      startDate: dateFormatter.date(from: "2022/09/02 20:00")!, color: .blue),
            DemoEvent(title: "Watching Movie", fullfilment: 75,
                      startDate: dateFormatter.date(from: "2022/09/03 19:00")!, color: .green)
        ]
    }
}
