//
//  EventDetailDiary.swift
//  LifeLog
//
//  Created by Genki on 12/22/23.
//

import SwiftUI

struct EventDetailDiary: View {
    @Binding var date: Date
    @Binding var showDiary: Bool
    let items: FetchedResults<DateItem>?
    var body: some View {
        VStack(spacing: 8) {
            if let item = items {
                if item.first?.dialy == "" && item.first?.images == nil || item.isEmpty {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 15))
                        Text("Write a Diary")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        showDiary = true
                    }
                } else {
                    HStack(alignment: .top) {
                        if let text = item.first?.dialy {
                            Text(text)
                                .lineLimit(6)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer()
                        if let imageData = item.first?.images {
                            if let uiimage = imagesFromCoreData(object: imageData)?.first {
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
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 0))
                    .onTapGesture {
                        showDiary.toggle()
                    }
                }
            }
        }.padding(.bottom, 20)
    }
}
