//
//  TagChartDemo.swift
//  LifeLog
//
//  Created by Genki on 1/22/24.
//

import SwiftUI

struct TagChartDemo: View {
    let values = [1800, 900, 870, 630, 500, 400, 300]
    let names = ["Work", "Study", "SNS", "Housework", "Leisure", "Relax", "Workout"]
                 let color: [Color] = [.blue, .green, .cyan, .pink, .purple, .red, .orange]
    var widthFraction: CGFloat = 0.75
    var innerRadiusFraction: CGFloat = 0.60
    var geometry: GeometryProxy
    private func pieSliceData() -> [PieSliceData] {
            let sum = values.reduce(0, +)
            var endDeg: Double = 0
            var tempSlices: [PieSliceData] = []
        for index in values.indices {
            let degrees: Double = Double(values[index] * 360 / sum)
            tempSlices.append(PieSliceData(
                startAngle: Angle(degrees: endDeg),
                endAngle: Angle(degrees: endDeg + degrees),
                text: names[index], color: color[index],
                percentage: Double(values[index] * 100 / sum)))
                endDeg += degrees
            }
            return tempSlices
        }
    var body: some View {
            VStack {
                ZStack {
                    ForEach(pieSliceData(), id: \.self) { item in
                        PieSlice(pieSliceData: item)
                    }
                    .frame(width: geometry.size.width, height: widthFraction * geometry.size.width)
                    Circle()
                        .fill(Color("whiteBlack"))
                        .frame(width: widthFraction * geometry.size.width * innerRadiusFraction,
                               height: widthFraction * geometry.size.width * innerRadiusFraction)
                    VStack {
                        Text("Total")
                        Text(valueToString(value: values.reduce(0, +)))
                    }.font(.title2)
                }
                .padding(.vertical)
                HStack(spacing: 12) {
                    Button {
                    } label: {
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("iconColor"))
                    }
                    Text("Jan 21 - 27, 2024")
                        .font(.system(size: 14))
                    Button {
                    } label: {
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("iconColor"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                VStack {
                    ForEach(0..<7) { index in
                        let ratio: Double = Double(Double(values[index]) / Double(values[0]))
                        VStack(spacing: 2) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(color[index])
                                    .font(.system(size: 10))
                                Text(names[index])
                                    .font(.system(size: 14))
                                Spacer()
                            }
                            HStack {
                                Rectangle()
                                    .cornerRadius(100)
                                    .frame(width: (UIScreen.main.bounds.width * 0.70) * ratio, height: 5)
                                    .foregroundColor(Color(UIColor.placeholderText))
                                Text(valueToString(value: values[index]))
                                    .foregroundStyle(.gray)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.031))
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                    }
                }
                .padding(.top)
            }
    }
    private func valueToString(value: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated

        let minutes = value % 60
        let hours = value / 60
        var components = DateComponents()
        components.hour = hours
        components.minute = minutes

        return formatter.string(from: components) ?? ""
    }

}
