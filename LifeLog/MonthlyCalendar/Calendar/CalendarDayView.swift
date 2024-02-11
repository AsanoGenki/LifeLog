//
//  CalendarDayView.swift
//  Calendar
//
//  Created by Genki on 10/17/23.
//

import HorizonCalendar
import SwiftUI

struct CalendarDayView: View {

  let dayNumber: Int
  let isSelected: Bool

  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        .background {
          Circle()
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : .clear)
        }
        .aspectRatio(1, contentMode: .fill)
      Text("\(dayNumber)").foregroundColor(Color(UIColor.label))
    }
  }

}

struct CalendarDayView_Previews: PreviewProvider {

  static var previews: some View {
    Group {
        CalendarDayView(dayNumber: 1, isSelected: false)
        CalendarDayView(dayNumber: 19, isSelected: false)
        CalendarDayView(dayNumber: 27, isSelected: true)
    }
    .frame(width: 50, height: 50)
  }

  private static let calendar = Calendar.current
}
