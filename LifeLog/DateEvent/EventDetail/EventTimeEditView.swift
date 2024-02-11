//
//  EventTimeEditView.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI

struct EventTimeEditView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State var showStartCalendar = false
    @State var showStartHourAndMinute = false
    @State var showEndCalendar = false
    @State var showEndHourAndMinute = false
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .frame(width: 20, alignment: .leading)
            Text("Starts")
            Spacer()
            Text(weekDayToMonth(date: startDate))
                .font(.system(size: 14))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .foregroundColor(showStartCalendar ?
                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)) : .primary)
                .background(showStartCalendar ?
                            Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        showStartHourAndMinute = false
                        showEndCalendar = false
                        showEndHourAndMinute = false
                        showStartCalendar.toggle()
                    }
                }
            Text(timeString(date: startDate))
                .font(.system(size: 14))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .foregroundColor(showStartHourAndMinute ?
                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)) : .primary)
                .background(showStartHourAndMinute ?
                            Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        showEndCalendar = false
                        showEndHourAndMinute = false
                        showStartCalendar = false
                        showStartHourAndMinute.toggle()
                    }
                }
        }
        if showStartCalendar {
            DatePicker(
                "Start Date",
                selection: $startDate,
                displayedComponents: [.date]
            ).datePickerStyle(.graphical)
                .animation(.default, value: showStartCalendar)
                .accentColor(Color(UIColor.rgba(red: 147, green: 112, blue: 219, alpha: 1)))
        }
        if showStartHourAndMinute {
            DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
        }
        HStack {
            Rectangle()
                .frame(width: 20)
                .foregroundColor(.clear)
            Text("Ends")
            Spacer()
            Text(weekDayToMonth(date: endDate))
                .font(.system(size: 14))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .strikethrough(endDate < startDate)
                .foregroundColor(showEndCalendar ?
                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)) : .primary)
                .background(showEndCalendar ?
                            Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        showStartCalendar = false
                        showStartHourAndMinute = false
                        showEndHourAndMinute = false
                        showEndCalendar.toggle()
                    }
                }
            Text(timeString(date: endDate))
                .font(.system(size: 14))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .strikethrough(endDate < startDate)
                .foregroundColor(showEndHourAndMinute ?
                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)) : .primary)
                .background(showEndHourAndMinute ?
                            Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        showStartCalendar = false
                        showStartHourAndMinute = false
                        showEndCalendar = false
                        showEndHourAndMinute.toggle()
                    }
                }
        }
        if showEndCalendar {
            DatePicker(
                "Ends Date",
                selection: $endDate,
                displayedComponents: [.date]
            ).datePickerStyle(.graphical)
                .animation(.default, value: showEndCalendar)
                .accentColor(Color(UIColor.rgba(red: 147, green: 112, blue: 219, alpha: 1)))
        }
        if showEndHourAndMinute {
            DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
        }
    }
}
