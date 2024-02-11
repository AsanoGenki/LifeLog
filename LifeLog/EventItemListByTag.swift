//
//  EventItemByTagID.swift
//  LifeLog
//
//  Created by Genki on 12/28/23.
//

import SwiftUI

struct EventItemListByTag: View {
    @State var showEditEventView = false
    @State var createDate = UUID()
    @State var title = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var itemFulfillment: Double = 50.0
    @State var color: Color = .purple
    @State var memo = ""
    @State var id: UUID = UUID()
    @State var calendarID = UUID()
    @Binding var tagName: String
    let calendarItem: FetchedResults<CalendarItem>?
    var body: some View {
        NavigationView {
            if let items = calendarItem {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("\(items.count) Events")
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    ForEach(items) { event in
                        if let eventColor = event.tag?.color,
                           let eventTitle = event.title,
                           let eventStartDate = event.startDate,
                           let eventEndDate = event.endDate,
                           let eventId = event.id,
                           let eventMemo = event.memo {
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
                                title = eventTitle
                                startDate = eventStartDate
                                endDate = eventEndDate
                                id = eventId
                                memo = eventMemo
                                itemFulfillment = Double(event.adequancy)
                                if let eventTagId = event.tag?.id {
                                    calendarID = eventTagId
                                }
                                showEditEventView.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle(tagName)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showEditEventView) {
                    EditEventView(
                        adequancy: $itemFulfillment,
                        calendarID: $calendarID,
                        createDate: $createDate,
                        endDate: $endDate,
                        id: $id,
                        memo: $memo,
                        startDate: $startDate,
                        title: $title
                    )
                }
            }
        }
    }
}
