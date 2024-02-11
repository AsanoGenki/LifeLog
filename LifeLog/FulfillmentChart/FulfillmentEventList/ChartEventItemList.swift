//
//  ChartEventItemList.swift
//  LifeLog
//
//  Created by Genki on 2/9/24.
//

import SwiftUI
import CoreData

struct ChartEventItemList: View {
    @Binding var showFilterChartTagView: Bool
    @ObservedObject var viewModel: ChartViewModel
    @FetchRequest(sortDescriptors: []) var tag: FetchedResults<EventTag>
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\CalendarItem.startDate, order: .reverse)]
    ) var eventItem: FetchedResults<CalendarItem>
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\DateItem.date, order: .reverse)]
    ) var dateItem: FetchedResults<DateItem>
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @AppStorage("displayDate") var displayDate = Date()
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            Button {
                showFilterChartTagView = true
            } label: {
                HStack(spacing: 4) {
                    if viewModel.filterTag != nil {
                        if let defaultType = getCalendarTypeById(id: viewModel.model.filterTag!).first {
                            Image(systemName: "circle.fill")
                                .foregroundColor(convertDataToColor(data: defaultType.color!))
                                .font(.system(size: 10))
                            Text((defaultType.name)!)
                        }
                    } else {
                        Image(systemName: "tag")
                        Text("All")
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.primary)
            }
            Menu {
                Button {
                    viewModel.changeEventListSort(sort: .recently)
                    eventItem.sortDescriptors = [
                        SortDescriptor(\CalendarItem.startDate, order: .reverse)]
                    dateItem.sortDescriptors = [SortDescriptor(\DateItem.date, order: .reverse)]
                } label: {
                    Text(LocalizedStringKey(EventListSort.recently.text))
                }
                Button {
                    viewModel.changeEventListSort(sort: .old)
                    eventItem.sortDescriptors = [SortDescriptor(\CalendarItem.startDate)]
                    dateItem.sortDescriptors = [SortDescriptor(\DateItem.date)]
                } label: {
                    Text(LocalizedStringKey(EventListSort.old.text))
                }
                Button {
                    viewModel.changeEventListSort(sort: .high)
                    eventItem.sortDescriptors = [
                        SortDescriptor(\CalendarItem.adequancy, order: .reverse)]
                    dateItem.sortDescriptors = [
                        SortDescriptor(\DateItem.adequancy, order: .reverse)]
                } label: {
                    Text(LocalizedStringKey(EventListSort.high.text))
                }
                Button {
                    viewModel.changeEventListSort(sort: .low)
                    eventItem.sortDescriptors = [SortDescriptor(\CalendarItem.adequancy)]
                    dateItem.sortDescriptors = [SortDescriptor(\DateItem.adequancy)]
                } label: {
                    Text(LocalizedStringKey(EventListSort.low.text))
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text(LocalizedStringKey(viewModel.eventListSort.text))
                }.font(.system(size: 12))
                    .foregroundColor(.primary)
            }
        }
        .padding(.bottom, 6)
        if viewModel.selectedDateTab == .day || viewModel.selectedDateTab == .week || entitlementManager.hasPro {
            EventItemList(
                viewModel: viewModel,
                displayDate: $displayDate
            )
        }
        Rectangle()
            .frame(width: 1, height: 60)
            .foregroundStyle(.clear)
    }
    func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
}
