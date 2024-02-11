//
//  ContentView.swift
//  LifeLog
//
//  Created by Genki on 10/29/23.
//

import SwiftUI
import CoreData
import AdSupport

enum Tab: String {
    case calendar
    case dialy
    case timerList
    case pie
    case chart
}

struct ContentView: View {
    @AppStorage("selectionTab") var selection: Tab = .calendar
    @State private var lastSelection: Tab = .calendar
    @State var showEventEdit = false
    @State var createDate = UUID()
    @State var title = ""
    @State private var selectedItem = 1
    @State private var oldSelectedItem = 1
    @State var startDate = Date()
    @State var endDate = Date()
    @StateObject var countUpViewModel = CountUpTimerViewModel()
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @AppStorage("repeatTime") var repeatTime = 90
    func loadData() {
        notificationViewModel.deleteNotification()
        if repeatTime > 0 {
            notificationViewModel.repeatAlert()
        }
    }
    init() {
        let image = UIImage.gradientImageWithBounds(
            bounds: CGRect( x: 0, y: 0, width: UIScreen.main.scale, height: 0.25),
            colors: [
                UIColor.clear.cgColor,
                UIColor.gray.withAlphaComponent(0.5).cgColor
            ]
        )
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemGray6
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = image
        UITabBar.appearance().backgroundColor = UIColor(Color("whiteBlack"))
        UITabBar.appearance().standardAppearance = appearance
    }
    @State private var playerOffset: CGFloat = 0
    @AppStorage("showStartView") var showStartView = true
    var body: some View {
        if !showStartView {
            TabView(selection: $selection) {
                TodayEvent()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Home")
                    }.tag(Tab.calendar)
                TimerListView()
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Timer")
                    }.tag(Tab.timerList)
                DiaryView()
                    .tabItem {
                        Image(systemName: "book.pages")
                        Text("Diary")
                    }.tag(Tab.dialy)
                TagChartView()
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("Chart")
                    }.tag(Tab.pie)
                FulFillmentChartView()
                    .tabItem {
                        Image(systemName: "chart.dots.scatter")
                        Text("Insights")
                    }.tag(Tab.chart)
            }
            .accentColor(Color("iconColor"))
            .onChange(of: selection) { _ in
                switch selection {
                case .calendar, .timerList, .chart, .dialy, .pie:
                    lastSelection = selection
                }
            }
            .onAppear {
                loadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    AdmobManager().checkTrackingAuthorizationStatus()
                }
            }
            .sheet(
                isPresented: $showEventEdit,
                onDismiss: {
                    self.selectedItem = self.oldSelectedItem
                },
                content: {
                    NavigationStack {
                        CreateEventView(title: $title,
                                        startDate: $startDate,
                                        endDate: $endDate,
                                        createDate: $createDate)
                    }
                }
            )
            .environmentObject(countUpViewModel)
            .onOpenURL(perform: { url in
                if url.absoluteString == "lifelog-scheme://CreateCalendarView" {
                    endDate = Date()
                    startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
                    showEventEdit = true
                } else if url.absoluteString == "lifelog-scheme://TimerListView" {
                    selection = Tab.timerList
                } else {
                    selection = Tab.calendar
                    endDate = Date()
                    startDate = Calendar.current.date(byAdding: .minute, value: -repeatTime, to: Date())!
                    showEventEdit = true
                }
            })
        } else {
            StartView()
        }
    }
}
