//
//  DialyItemView.swift
//  LifeLog
//
//  Created by Genki on 11/18/23.
//

import SwiftUI

struct DialyItemListView: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\DateItem.date, order: .reverse)])
    var dateItem: FetchedResults<DateItem>
    @EnvironmentObject private var weekStore: WeekCalendarManager
    @State var showDialy = false
    @State var adequancy = 0
    @State var date = Date()
    @State var eventDate = Date()
    @Binding var selectSort: Int
    @Binding var startDate: Date
    @Binding var endDate: Date
    @AppStorage("selectionTab") var selection: Tab = .calendar
    var body: some View {
        LazyVStack {
            ForEach(dateItem, id: \.self) { item in
                if item.dialy != "" && item.images != nil {
                    DiaryItemView(
                        date: $date,
                        showDialy: $showDialy,
                        adequancy: $adequancy,
                        selection: $selection,
                        item: item
                    )
                }
            }
        }
        .onChange(of: selectSort) { _ in
            switch selectSort {
            case 0:
                dateItem.sortDescriptors = [SortDescriptor(\DateItem.date, order: .reverse)]
            case 1:
                dateItem.sortDescriptors = [SortDescriptor(\DateItem.date)]
            case 2:
                dateItem.sortDescriptors = [SortDescriptor(\DateItem.adequancy, order: .reverse)]
            case 3:
                dateItem.sortDescriptors = [SortDescriptor(\DateItem.adequancy)]
            default:
                break
            }
        }
        .onChange(of: [startDate, endDate]) { _ in
            getCalendarItem()
        }
    }
    func getCalendarItem() {
        let predicate = NSPredicate(
            format: "(%@ <= date) AND (date <= %@)",
            startDate as NSDate,
            endDate as NSDate)
        dateItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
    }
}

func dateToDiaryString(date: Date) -> String {
    let formatter = DateFormatter()
    let calendar = Calendar.current
    if Locale.current.language.languageCode?.identifier == "ja" {
        if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
            formatter.dateFormat = "MMMd日(EEE)"
        } else {
            formatter.dateFormat = "yyyy年MMMd日(EEE)"
        }
    } else {
        if calendar.component(.year, from: date) == calendar.component(.year, from: Date()) {
            formatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, yyyy")
        }
    }
    return formatter.string(from: date)
}
