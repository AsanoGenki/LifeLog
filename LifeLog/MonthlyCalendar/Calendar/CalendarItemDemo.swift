//
//  CalendarItemDemo.swift
//  LifeLog
//
//  Created by Genki on 12/30/23.
//

import SwiftUI
import CoreData
import HorizonCalendar

struct CalendarItemDemo: View {
    let circleColor: Color
    let numberColor: Color
    let day: DayComponents
    var body: some View {
        VStack(spacing: 2) {
            Divider()
            ZStack(alignment: .center) {
                Circle().foregroundColor(circleColor)
                    .frame(width: 20, height: 20)
                Text("\(day.day)")
                    .foregroundColor(numberColor)
                    .font(.system(size: 12))
            }
            Spacer()
        }.frame(height: 110)
    }
}
