//
//  LifeLogApp.swift
//  LifeLog
//
//  Created by Genki on 10/29/23.
//

import SwiftUI
import UserNotifications
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency
import FamilyControls

@main
struct LifeLogApp: App {
    let persistenceController = PersistenceController.shared.managedObjectContext
    @ObservedObject var center = AuthorizationCenter.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var purchaseManager: PurchaseManager
    @StateObject private var networkMonitor: NetworkMonitor
    @StateObject private var countDownTimerViewModel: CountDownTimerViewModel
    @StateObject private var appBlockViewModel: AppBlockViewModel
    @StateObject var weekStore: WeekCalendarManager
    @AppStorage("appBlockAuthority") var appBlockAuthority = false
    init() {
        let entitlementManager = EntitlementManager()
        let purchaseManager = PurchaseManager(entitlementManager: entitlementManager)
        let networkMonitor = NetworkMonitor()
        let weekStore = WeekCalendarManager()
        let countDownTimerViewModel = CountDownTimerViewModel()
        let appBlockViewModel = AppBlockViewModel()
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._purchaseManager = StateObject(wrappedValue: purchaseManager)
        self._networkMonitor = StateObject(wrappedValue: networkMonitor)
        self._weekStore = StateObject(wrappedValue: weekStore)
        self._countDownTimerViewModel = StateObject(wrappedValue: countDownTimerViewModel)
        self._appBlockViewModel = StateObject(wrappedValue: appBlockViewModel)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController)
                .environmentObject(entitlementManager)
                .environmentObject(purchaseManager)
                .environmentObject(networkMonitor)
                .environmentObject(weekStore)
                .environmentObject(NotificationViewModel())
                .environmentObject(countDownTimerViewModel)
                .environmentObject(appBlockViewModel)
                .task {
                    await purchaseManager.updatePurchasedProducts()
                }
                .onReceive(center.$authorizationStatus) { status in
                    appBlockAuthority = status == .approved
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    @AppStorage("calendarSelectedDate") var calendarSelectedDate = Date()
    @AppStorage("showCalendar") var showCalendar = false
    @AppStorage("selectionTab") var selection: Tab = .calendar
    @AppStorage("displayDate") var displayDate = Date()
    @AppStorage("pieChartDate") var pieChartDate = Date()
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        calendarSelectedDate = Date()
        showCalendar = false
        selection = .calendar
        displayDate = Date()
        pieChartDate = Date()
        return true
    }
}
