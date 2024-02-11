//
//  SettingView.swift
//  LifeLog
//
//  Created by Genki on 11/13/23.
//

import SwiftUI
import UserNotifications

struct SettingView: View {
    @State private var notificationAllow = true
    @State private var showingAlert = false
    @State var showPremiumView = false
    @AppStorage("notificationStartTime")
    var notificationStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @AppStorage("notificationEndTime")
    var notificationEndTime = Calendar.current.date(
        bySettingHour: 22, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @AppStorage("repeatTime") var repeatTime = 90
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @State var progress: CGFloat = 60
    @AppStorage("imageData") var imageData = 0.0
    @AppStorage("defaultTagID") var defaultTagID: UUID = UUID()
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @FetchRequest(sortDescriptors: []) var tag: FetchedResults<EventTag>
    @State var showTagPicker = false
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Alert")) {
                    if notificationAllow {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Menu {
                                Button("No alert", action: {
                                    notificationViewModel.deleteNotification()
                                    repeatTime = 0
                                })
                                Button {
                                    if entitlementManager.hasPro {
                                        repeatTime = 30
                                        changeRepeatTime(time: 30)
                                    } else {
                                        showPremiumView = true
                                    }
                                } label: {
                                    Text("every 30 min")
                                    if !entitlementManager.hasPro {
                                        Image(systemName: "lock")
                                    }
                                }
                                Button {
                                    repeatTime = 60
                                    changeRepeatTime(time: 60)
                                } label: {
                                    Text("every 60 min")
                                }
                                Button {
                                    repeatTime = 90
                                    changeRepeatTime(time: 90)
                                } label: {
                                    Text("every 90 min")
                                }
                                Button {
                                    if entitlementManager.hasPro {
                                        repeatTime = 120
                                        changeRepeatTime(time: 120)
                                    } else {
                                        showPremiumView = true
                                    }
                                } label: {
                                    Text("every 120 min")
                                    if !entitlementManager.hasPro {
                                        Image(systemName: "lock")
                                    }
                                }
                                Button {
                                    if entitlementManager.hasPro {
                                        repeatTime = 180
                                        changeRepeatTime(time: 180)
                                    } else {
                                        showPremiumView = true
                                    }
                                } label: {
                                    Text("every 180 min")
                                    if !entitlementManager.hasPro {
                                        Image(systemName: "lock")
                                    }
                                }
                                Button {
                                    if entitlementManager.hasPro {
                                        repeatTime = 240
                                        changeRepeatTime(time: 240)
                                    } else {
                                        showPremiumView = true
                                    }
                                } label: {
                                    Text("every 240 min")
                                    if !entitlementManager.hasPro {
                                        Image(systemName: "lock")
                                    }
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    Text(repeatTime > 0 ? "every \(repeatTime) min" : "No alert")
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                }
                            }.foregroundColor(.primary)
                        }
                        HStack {
                            DatePicker("Start", selection: $notificationStartTime, displayedComponents: .hourAndMinute)
                        }
                        HStack {
                            Text("End")
                            Spacer()
                            DatePicker("", selection: $notificationEndTime, displayedComponents: .hourAndMinute)
                        }
                        .onChange(of: [notificationStartTime, notificationEndTime]) { _ in
                            changeRepeatTime(time: repeatTime)
                        }
                    } else {
                        Button("Allow notifications") {
                            self.showingAlert = true
                        }
                    }
                }.textCase(nil)
                if !entitlementManager.hasPro {
                    Button {
                        showPremiumView = true
                    } label: {
                        HStack {
                            Image(systemName: "crown")
                                .font(.system(size: 18))
                                .foregroundColor(Color("gptPurple"))
                            Text("Premium")
                        }
                    }.foregroundColor(.primary)
                }
                HStack {
                    Image(systemName: "tag")
                        .font(.system(size: 18))
                    Text("Default Tag")
                    Spacer()
                    Button {
                        showTagPicker = true
                    } label: {
                        HStack(spacing: 3) {
                            if let defaultType = getCalendarTypeById(id: defaultTagID).first {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(convertDataToColor(data: defaultType.color!))
                                    .font(.system(size: 10))
                                Text((defaultType.name)!)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12))
                            }
                        }.foregroundColor(.primary)
                    }
                }
                VStack {
                    HStack {
                        Image(systemName: "cloud")
                        Text("Image Storage")
                        Spacer()
                        if !entitlementManager.hasPro {
                            if imageData > 150 {
                                Text("150") +
                                Text(" / 150MB")
                            } else {
                                Text(String(format: "%.1fMB", imageData)) +
                                Text(" / 150MB")
                            }
                        } else {
                            if imageData < 1000 {
                                Text(String(format: "%.1fMB", imageData)) +
                                Text(" / ∞")
                            } else {
                                Text(String(format: "%.1fGB", mbTogb(data: imageData))) +
                                Text(" / ∞")
                            }
                        }
                    }
                    .onAppear {
                        progress = (imageData / 150) * 100
                    }
                    if !entitlementManager.hasPro {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray)
                                .opacity(0.3)
                                .frame(height: 4.0)
                                .cornerRadius(100)
                            Rectangle()
                                .foregroundColor(Color.blue)
                                .frame(width: 345.0 * (self.progress / 100.0), height: 4)
                                .cornerRadius(100)
                        }
                        .padding(.bottom, 8)
                    }
                }
                if !entitlementManager.hasPro {
                    if networkMonitor.isConnected {
                        BannerAdView(adUnit: .mainView, adFormat: .mediumRectangle)
                    } else {
                        PremiumAdsView()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("timerListBackground"), for: .navigationBar)
        }
        .onAppear {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    notificationAllow = true
                } else {
                    notificationAllow = false
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Notifications are disabled"),
                message: Text("Please enable notifications from the settings."),
                primaryButton: .default(Text("Settings"), action: {
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }), secondaryButton: .cancel(Text("Cancel")))
        }
        .fullScreenCover(isPresented: $showPremiumView) {
            PremiumView()
        }
        .sheet(isPresented: $showTagPicker) {
            SelectDefaultTagView()
        }
    }
    private func changeRepeatTime(time: Int) {
        repeatTime = time
        notificationViewModel.deleteNotification()
        notificationViewModel.repeatAlert()
    }
    private func mbTogb(data: Double) -> Double {
        return data / 1000
    }
    private func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
}

#Preview {
    SettingView()
}
