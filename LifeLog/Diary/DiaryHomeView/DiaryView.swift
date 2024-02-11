//
//  DiaryView.swift
//  LifeLog
//
//  Created by Genki on 11/21/23.
//

import SwiftUI
import CoreData

struct DiaryView: View {
    @State var showDialy = false
    @State var adequancy = 0
    @State var date = Date()
    @State var showPhotoList = false
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @State private var selectSort = 0
    @State private var showDiaryFilter = false
    @State var startDate = Date()
    @State var endDate = Date()
    @State var isOnFilter = false
    let sort = ["Recently", "Old", "High Fulfillment", "Low Fulfillment"]
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List {
                        HStack(spacing: 4) {
                            Spacer()
                            Button {
                                showDiaryFilter = true
                            } label: {
                                if !isOnFilter {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                } else {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                        .foregroundColor(Color("iconColor"))
                                }
                            }
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .buttonStyle(.plain)
                        }
                        .font(.system(size: 13))
                        .frame(height: 10)
                        .listRowSeparator(.hidden)
                        DialyItemListView(selectSort: $selectSort, startDate: $startDate, endDate: $endDate)
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(top: 0,
                                           leading: 0,
                                           bottom: 10,
                                           trailing: 0
                                          )
                            )
                        Rectangle()
                            .frame(width: 100, height: 60)
                            .foregroundColor(Color("whiteBlack"))
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.inset)
                    .environment(\.defaultMinListRowHeight, 10)
                }
                .navigationTitle("Diary")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    showPhotoList = true
                }, label: {
                    Image(systemName: "photo")
                        .font(.system(size: 14))
                }).foregroundStyle(.primary), trailing: Button(action: {
                    date = Date()
                    let calendar = Calendar.current
                    let startComponents = DateComponents(
                        year: calendar.component(.year, from: date),
                        month: calendar.component(.month, from: date),
                        day: calendar.component(.day, from: date),
                        hour: 0,
                        minute: 0,
                        second: 0)
                    date =  calendar.date(from: startComponents)!
                    showDialy = true
                    print(date)
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                }).foregroundStyle(.primary))
                .sheet(
                    isPresented: $showPhotoList,
                    onDismiss: {
                        showPhotoList = false
                    },
                    content: {
                        PhotoGridView()
                    }
                )
                .sheet(isPresented: $showDiaryFilter) {
                    DiaryFilterView(
                        startDate: $startDate,
                        endDate: $endDate,
                        selectedSort: $selectSort,
                        isOnFilter: $isOnFilter
                    )
                }
                VStack {
                    Spacer()
                    if !entitlementManager.hasPro {
                        if networkMonitor.isConnected {
                            BannerAdView(adUnit: .mainView, adFormat: .adaptiveBanner)
                        } else {
                            PremiumAdsView()
                        }
                    }
                }
            }
            .onAppear {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: Date())
                let nowDate = calendar.date(from: components)!
                startDate = calendar.date(byAdding: .month, value: -6, to: nowDate)!
                endDate = calendar.date(byAdding: .month, value: +6, to: nowDate)!
            }
        }
        .fullScreenCover(isPresented: $showDialy) {
            DiaryEditView(date: $date)
        }
    }
}

#Preview {
    DiaryView()
}
