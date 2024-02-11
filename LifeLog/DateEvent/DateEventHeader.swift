//
//  DateEventHeader.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI

struct DateEventHeader: View {
    @EnvironmentObject private var weekStore: WeekCalendarManager
    @Binding var showDatePicker: Bool
    @Binding var showSearch: Bool
    @Binding var showCalendar: Bool
    @Binding var showSettings: Bool
    var body: some View {
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            @Environment(\.locale) var locale
            if Locale.current.language.languageCode?.identifier == "ja" {
                dateFormatter.dateFormat = "yyyy年MMM"
            } else {
                dateFormatter.dateFormat = "MMM yyyy"
            }
            return dateFormatter
        }()
        let monthTitle = dateFormatter.string(from: weekStore.currentDate)
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        HStack(spacing: 18) {
            Text(monthTitle)
                .font(.system(size: width * 0.058)
                    .monospacedDigit())
                .frame(alignment: .leading)
                .onTapGesture {
                    showDatePicker = true
                }
            Spacer()
            Button {
                showSearch.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: width * 0.055))
            }.foregroundStyle(.primary)
            Button {
                weekStore.goToday()
            } label: {
                Image("todayIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width * 0.052, height: UIScreen.main.bounds.width * 0.052)
            }
            Button {
                showCalendar.toggle()
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: width * 0.055))
            }.foregroundStyle(.primary)
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: width * 0.055))
            }.foregroundStyle(.primary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
    }
}
