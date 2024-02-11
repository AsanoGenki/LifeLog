//
//  DiaryItemContentView.swift
//  LifeLog
//
//  Created by Genki on 1/26/24.
//

import SwiftUI

struct DiaryItemView: View {
    @Binding var date: Date
    @Binding var showDialy: Bool
    @Binding var adequancy: Int
    @Binding var selection: Tab
    var item: FetchedResults<DateItem>.Element
    @EnvironmentObject private var weekStore: WeekCalendarManager

    var body: some View {
        VStack {
            Text(dateToDiaryString(date: item.date ?? Date()))
                .font(.system(size: 14))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            Divider()
                .padding(.leading, 10)
            HStack(alignment: .top) {
                VStack {
                    if item.adequancy != -1 {
                        returnFace(adequancy: Int(item.adequancy))
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("\(item.adequancy)")
                            .font(.system(size: 10))
                    } else {
                        VStack {
                            Image("noFace")
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text("-")
                                .font(.system(size: 10))
                        }
                    }
                }
                .padding([.trailing, .leading], 6)
                .padding(.top, 3)
                .onTapGesture {
                    weekStore.currentDate = item.date ?? Date()
                    weekStore.initWeeklyCalendar()
                    selection = .calendar
                }
                Text(item.dialy ?? "")
                    .lineLimit(6)
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let imageData = item.images, let uiimage = imagesFromCoreData(object: imageData)?.first {
                    ZStack {
                        if imagesFromCoreData(object: imageData)!.count > 1 {
                            Rectangle()
                                .frame(width: 90, height: 100)
                                .padding(.bottom, 8)
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                        Image(uiImage: uiimage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 10)
            .contentShape(RoundedRectangle(cornerRadius: 0))
            .onTapGesture {
                date = item.date!
                adequancy = Int(item.adequancy)
                showDialy = true
            }
            .fullScreenCover(isPresented: $showDialy) {
                DiaryEditView(date: $date)
            }
        }
    }
}
