//
//  ChartView.swift
//  LifeLog
//
//  Created by Genki on 11/8/23.
//

import SwiftUI
import Charts
import CoreData
import Algorithms

struct FulFillmentChartView: View {
    @AppStorage("displayDate") var displayDate = Date()
    @AppStorage("selectionTab") var selection: Tab = .calendar
    @FetchRequest(sortDescriptors: []) var calendarItem: FetchedResults<CalendarItem>
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @State var showPremium = false
    @State var showFilterChartTagView = false
    @ObservedObject var viewModel: ChartViewModel = ChartViewModel()
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    Picker("", selection: $viewModel.model.chartDateTab) {
                        ForEach(DateTab.allCases, id: \.self) { dateTab in
                            Text(LocalizedStringKey(dateTab.text))
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedDateTab) { _ in
                        viewModel.model.selectedElement = nil
                        if !entitlementManager.hasPro &&
                            viewModel.selectedDateTab != .day &&
                            viewModel.selectedDateTab != .week {
                            showPremium = true
                        }
                    }
                    ZStack {
                        VStack {
                            VStack {
                                VStack(spacing: 20) {
                                    if viewModel.selectedDateTab == .day {
                                        DayChart(displayDate: $displayDate)
                                    }
                                    if viewModel.selectedDateTab == .week {
                                        WeeklyChart(dates: getThisWeekDates(displayDate: displayDate),
                                                    displayDate: $displayDate)
                                    } else if viewModel.selectedDateTab == .month {
                                        MonthlyChart(
                                            dates: getThisMonthDates(displayDate: displayDate),
                                            displayDate: $displayDate,
                                            viewModel: viewModel
                                        )
                                    } else if viewModel.selectedDateTab == .sixMonth {
                                        HalfYearlyChart(
                                            dates: getWeeklyDates(displayDate: displayDate),
                                            displayDate: $displayDate,
                                            sixMonthDates: getThis6MonthDates(displayDate: displayDate),
                                            viewModel: viewModel
                                        )
                                    }
                                    HStack(spacing: 20) {
                                        Button {
                                            viewModel.displayToday()
                                            viewModel.changeSwipeDirection(inputSwipeDirection: .none)
                                        } label: {
                                            HStack {
                                                Image(systemName: "arrow.uturn.right")
                                                    .font(.system(size: 12))
                                                Text("Today")
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        .opacity(viewModel.swipeDirection != .left ? 0 : 1)
                                        .foregroundStyle(.primary)
                                        HStack(spacing: 12) {
                                            Button {
                                                viewModel.handleSwipeLeft()
                                            } label: {
                                                Image(systemName: "arrowtriangle.left.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color("iconColor"))
                                            }
                                            if viewModel.selectedDateTab == .day {
                                                Text(weekDayToYear(displayDate))
                                                    .font(.system(size: 14))
                                            } else if viewModel.selectedDateTab == .week {
                                                Text(datesToString(displayDate: displayDate))
                                                    .font(.system(size: 14))
                                            } else if viewModel.selectedDateTab == .month {
                                                Text(monthToYear(date: displayDate))
                                                    .font(.system(size: 14))
                                            } else if viewModel.selectedDateTab == .sixMonth {
                                                Text(dateRange(displayDate: displayDate))
                                                    .font(.system(size: 14))
                                            }
                                            Button {
                                                viewModel.handleSwipeRight()
                                            } label: {
                                                Image(systemName: "arrowtriangle.right.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color("iconColor"))
                                            }
                                        }.frame(maxWidth: .infinity)
                                        Button {
                                            viewModel.displayToday()
                                            viewModel.changeSwipeDirection(inputSwipeDirection: .none)
                                        } label: {
                                            HStack {
                                                Text("Today")
                                                    .font(.system(size: 12))
                                                Image(systemName: "arrow.uturn.left")
                                                    .font(.system(size: 12))
                                            }
                                        }.opacity(viewModel.swipeDirection != .right ? 0 : 1)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .padding(.bottom, 30)
                            ChartEventItemList(
                                showFilterChartTagView: $showFilterChartTagView,
                                viewModel: viewModel
                            )
                        }
                        if (viewModel.selectedDateTab == .month ||
                            viewModel.selectedDateTab == .sixMonth) &&
                            !entitlementManager.hasPro {
                            ZStack {
                                Color("whiteBlack")
                                DemoChartView()
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("whiteBlack").opacity(0.3),
                                        Color("whiteBlack").opacity(0.8),
                                        Color("whiteBlack").opacity(1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                HStack(spacing: 3) {
                                    Image(systemName: "lock")
                                    Text("Unlock with Premium")
                                }
                                .font(.headline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Color("buttonColor").cornerRadius(100))
                                .foregroundColor(Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)))
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 0))
                            .onTapGesture {
                                showPremium = true
                            }
                        }
                    }
                    .navigationTitle("Data")
                    .navigationBarTitleDisplayMode(.inline)
                }.padding(.horizontal)
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
            .gesture(
                DragGesture()
                    .onEnded { value in
                        viewModel.handleGesture(value: value)
                    }
            )
        }
        .fullScreenCover(isPresented: $showPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showFilterChartTagView) {
            FilterChartTagView(viewModel: viewModel)
        }
    }
}
