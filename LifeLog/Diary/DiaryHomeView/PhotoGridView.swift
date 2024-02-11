//
//  PhotoListView.swift
//  LifeLog
//
//  Created by Genki on 11/30/23.
//

import SwiftUI
import CoreData

struct PhotoGridView: View {
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\DateItem.date, order: .reverse)
    ]) var dateItem: FetchedResults<DateItem>
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    @AppStorage("imageData") var imageData = 0.0
    @State var showDialy = false
    @State var fullfilment = 0
    @State var date = Date()
    var body: some View {
        NavigationView {
            VStack {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(dateItem, id: \.self) { item in
                        if item.images?.count != 0 {
                            if let imageData = item.images {
                                if let images = imagesFromCoreData(object: imageData) {
                                    ForEach(0..<images.count, id: \.self) { index in
                                        let uiimage = images[index]
                                        Button {
                                            date = item.date!
                                            fullfilment = Int(item.adequancy)
                                            showDialy = true
                                        } label: {
                                            Image(uiImage: uiimage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: UIScreen.main.bounds.size.width / 3 - 1,
                                                    height: UIScreen.main.bounds.size.width / 3 - 1
                                                )
                                                .clipped()
                                        }
                                        .id(UUID())
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showDialy) {
                DiaryEditView(date: $date)
            }
        }
    }
}

#Preview {
    PhotoGridView()
}
