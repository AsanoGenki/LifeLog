//
//  TagDataView.swift
//  LifeLog
//
//  Created by Genki on 1/21/24.
//

import SwiftUI

struct TagDataView: View {
    @State private var progress = 0.5
    var items: [CalendarTypeSum]
    var body: some View {
        let firstTimeInterval: TimeInterval = items.first?.totalDuration ?? 0.0
        VStack {
            ForEach(items, id: \.self) { item in
                let ratio = item.totalDuration / firstTimeInterval
                if let itemName = item.tag.name, let itemColor = item.tag.color {
                    VStack(spacing: 2) {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(convertDataToColor(data: itemColor))
                                .font(.system(size: 10))
                            Text(itemName)
                                .font(.system(size: 14))
                            Spacer()
                        }
                        HStack {
                            Rectangle()
                                .cornerRadius(100)
                                .frame(width: (UIScreen.main.bounds.width * 0.70) * ratio, height: 5)
                                .foregroundColor(Color(UIColor.placeholderText))
                            Text(formattedTimeInterval(timeInterval: item.totalDuration))
                                .foregroundStyle(.gray)
                                .font(.system(size: UIScreen.main.bounds.width * 0.031))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                }
            }
        }
    }
}

func formattedTimeInterval(timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated

        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60

        var components = DateComponents()
        components.hour = hours
        components.minute = minutes

        return formatter.string(from: components) ?? ""
    }
