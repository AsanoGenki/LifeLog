//
//  SearchView.swift
//  LifeLog
//
//  Created by Genki on 11/13/23.
//

import SwiftUI
import CoreData
import GoogleMobileAds

struct SearchView: View {
    @State private var searchText = ""
    @FetchRequest(sortDescriptors: []) var calendarItem: FetchedResults<CalendarItem>
    @Environment(\.dismiss) private var dismiss
    @State var showCalendarView = false
    @State var startDate = Date()
    @State var createDate = UUID()
    @State var showPremium = false
    @FocusState private var focused: Bool
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var weekStore: WeekCalendarManager
    var body: some View {
        GeometryReader { _ in
            ZStack {
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search", text: $searchText)
                                .focused($focused)
                                .onChange(of: searchText) { newValue in
                                    DispatchQueue.main.async {
                                        searchText = newValue
                                    }
                                }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                        Text("Cancel")
                            .padding(.leading, 2)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                    .padding(.top, 20)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            focused = true
                        }
                        calendarItem.nsPredicate = nil
                    }
                    ScrollView {
                        if searchText == "" && !entitlementManager.hasPro && networkMonitor.isConnected {
                            VStack(alignment: .leading) {
                                HStack(spacing: 5) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("gptPurple"))
                                    Text("Try LifeLog Premium")
                                        .bold()
                                        .font(.system(size: 18))
                                        .foregroundColor(Color("adsTextColor"))
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                }
                                Text(["Unlock searching beyond a year, ",
                                      "No Ads, Unlimited Chart, Image capacity and more..."].joined())
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("adsTextColor"))
                                HStack {
                                    Spacer()
                                    Text("Try Premium")
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: 200, maxHeight: 50)
                                        .background(Color("gptPurple").cornerRadius(100))
                                        .foregroundColor(.white)
                                        .padding(.top, 10)
                                    Spacer()
                                }
                            }
                            .padding(8)
                            .padding(.bottom, 10)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("adsBackground2"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onTapGesture {
                                showPremium = true
                            }
                        }
                        if searchText != "" {
                            ForEach(searchItem(text: searchText)) { event in
                                if let eventColor = event.tag?.color,
                                   let eventTitle = event.title,
                                   let eventStartDate = event.startDate,
                                   let eventEndDate = event.endDate {
                                    HStack {
                                        Rectangle()
                                            .frame(width: 4, height: 34)
                                            .cornerRadius(100)
                                            .foregroundColor(convertDataToColor(data: eventColor))
                                        VStack(alignment: .leading) {
                                            Text(eventTitle)
                                            Text(eventItemDate(startDate: eventStartDate, endDate: eventEndDate))
                                                .font(.system(size: 10))
                                                .foregroundStyle(Color(UIColor.systemGray))
                                        }
                                        Spacer()
                                        if Int(event.adequancy) != -1 {
                                            HStack {
                                                returnFace(adequancy: Int(event.adequancy))
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                Text("\(event.adequancy)")
                                                    .font(.system(size: 14))
                                            }
                                        } else {
                                            HStack {
                                                Image("noFace")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                Text("-")
                                                    .font(.system(size: 14))
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(UIColor.quaternarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        weekStore.currentDate = eventStartDate
                                        weekStore.fetchCurrentWeek()
                                        weekStore.fetchPreviousNextWeek()
                                        weekStore.allWeeks.removeAll()
                                        weekStore.appendAll()
                                        weekStore.draggingItem = 0
                                        weekStore.snappedItem = 0
                                        dismiss()
                                    }
                                }
                            }
                        }
                        if !entitlementManager.hasPro {
                            if networkMonitor.isConnected {
                                BannerAdView(adUnit: .mainView, adFormat: .mediumRectangle)
                            } else {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color("gptPurple"))
                                        Text("Try LifeLog Premium")
                                            .bold()
                                            .font(.system(size: 18))
                                            .foregroundColor(Color("adsTextColor"))
                                            .padding(.top, 10)
                                            .padding(.bottom, 5)
                                    }
                                    Text(["Unlock searching beyond a year, No Ads, ",
                                          "Unlimited Chart, Image capacity and more..."].joined())
                                        .font(.system(size: 16))
                                        .foregroundColor(Color("adsTextColor"))
                                    HStack {
                                        Spacer()
                                        Text("Try Premium")
                                            .font(.system(size: 16))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 5)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: 200)
                                            .frame(height: 50)
                                            .background(Color("gptPurple").cornerRadius(100))
                                            .foregroundColor(.white)
                                            .padding(.top, 10)
                                        Spacer()
                                    }
                                }
                                .padding(8)
                                .padding(.bottom, 10)
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                                .background(Color("adsBackground2"))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onTapGesture {
                                    showPremium = true
                                }
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .sheet(isPresented: $showCalendarView) {
                EventDetailView(date: $startDate)
            }
            .fullScreenCover(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }
    private func searchItem(text: String) -> FetchedResults<CalendarItem> {
        if text.isEmpty {
            DispatchQueue.main.async {
                let id = UUID()
                let nilPredicate: NSPredicate = NSPredicate(format: "id = %@", id as CVarArg)
                calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nilPredicate])
            }
            return calendarItem
        } else {
            let titlePredicate: NSPredicate = NSPredicate(format: "title contains[cd] %@", text)
            if !entitlementManager.hasPro {
                DispatchQueue.main.async {
                    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
                    let startDate = Calendar.current.startOfDay(for: oneYearAgo)
                    let predicate = NSPredicate(format: "(%@ <= startDate)", startDate as NSDate)
                    calendarItem.nsPredicate = NSCompoundPredicate(
                        andPredicateWithSubpredicates: [titlePredicate, predicate]
                    )
                }
                return calendarItem
            }
            calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate])
            return calendarItem
        }
    }
}
