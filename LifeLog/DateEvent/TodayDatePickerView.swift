//
//  TodayDatePickerView.swift
//  LifeLog
//
//  Created by Genki on 1/22/24.
//

import SwiftUI

struct DetailDatePickerView: View {
    @Binding var showDatePicker: Bool
    @State var datePickerDate = Date()
    @State var showPremium = false
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var weekStore: WeekCalendarManager
    var body: some View {
        let startDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let visibleDateRange = startDate...endDate
        VStack {
            HStack {
                Button {
                    datePickerDate = Date()
                } label: {
                    Text("Today")
                }
                Spacer()
                Button {
                    weekStore.currentDate = datePickerDate
                    weekStore.initWeeklyCalendar()
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
        })
    }
}
