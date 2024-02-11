//
//  CustomDatePicker.swift
//  LifeLog
//
//  Created by Genki on 12/2/23.
//

import SwiftUI
import HorizonCalendar

struct DatePickerView: View {
    var calendarViewProxy: CalendarViewProxy
    let calendar: Calendar
    let visibleDateRange: ClosedRange<Date>
    @Binding var showDatePicker: Bool
    @State var datePickerDate = Date()
    @State var showPremium = false
    @EnvironmentObject private var entitlementManager: EntitlementManager
    var body: some View {
        VStack {
            HStack {
                Button {
                    datePickerDate = Date()
                } label: {
                    Text("Today")
                }
                Spacer()
                Button {
                    let displayYear = Calendar.current.component(.year, from: datePickerDate)
                    let displayMonth = Calendar.current.component(.month, from: datePickerDate)
                    let displayDay = Calendar.current.component(.day, from: datePickerDate)
                    calendarViewProxy.scrollToMonth(
                        containing: calendar.date(
                            from: DateComponents(
                                year: displayYear,
                                month: displayMonth,
                                day: displayDay))!,
                        scrollPosition: .centered,
                        animated: false)
                    showDatePicker = false
                } label: {
                    Text("Done")
                }
            }
            .padding(.top, 25)
            .padding(.horizontal)
            DatePicker("", selection: $datePickerDate, in: visibleDateRange, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
            if !entitlementManager.hasPro {
                HStack {
                    Text("Want to search beyond a year?")
                        .bold()
                        .font(.system(size: 16))
                        .foregroundColor(Color("textColorPurple"))
                    Spacer()
                    Text("Premium")
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color("gptPurple").cornerRadius(100))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("purpleBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .onTapGesture {
                    showPremium = true
                }
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showPremium, onDismiss: {
            showPremium = false
        }, content: {
            PremiumView()
        })    }
}
