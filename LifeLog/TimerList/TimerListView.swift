//
//  TimerListView.swift
//  LifeLog
//
//  Created by Genki on 10/31/23.
//

import SwiftUI
import CoreData
import SwipeableView
import FamilyControls

struct TimerListView: View {
    @FetchRequest(sortDescriptors: []) var timerItems: FetchedResults<TimerItem>
    @EnvironmentObject var countUpViewModel: CountUpTimerViewModel
    @State private var showCreateTimer = false
    @State private var showingSaveAlert = false
    @State private var showCreateCalendar = false
    @State private var createDate = UUID()
    @State private var endDate = Date()
    @State private var showStartQuickTimer = false
    @State private var showPremium = false
    @AppStorage("countUpisOn") private var countUpisOn = false
    @AppStorage("timerID") private var timerID: UUID?
    @AppStorage("startDate") private var startTimerDate = Date()
    @AppStorage("quickTimerName") private var quickTimerName = ""
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @AppStorage("appBlockAuthority") private var appBlockAuthority = false
    @AppStorage("blockAppSelecton") private var blockAppSelecton = FamilyActivitySelection()
    @AppStorage("countDownIsOn") private var countDownIsOn = false
    @State private var isShowingAppPicker = false
    let showWidget = WidgetController()
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    Picker("", selection: $countUpViewModel.model.timerTab) {
                        ForEach(TimerTab.allCases, id: \.self) { timerTab in
                            Text(LocalizedStringKey(timerTab.text))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .opacity(countDownIsOn == false && countUpisOn == false ? 1 : 0)
                    if countUpViewModel.timerTab == .countUp {
                        VStack(spacing: 14) {
                            if countUpisOn {
                                NowTimerView(showingSaveAlert: $showingSaveAlert, endDate: $endDate)
                            } else {
                                QuickTimer(showStartQuickTimer: $showStartQuickTimer)
                            }
                            if !countUpisOn {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button {
                                            if timerItems.count < 3 || entitlementManager.hasPro {
                                                showCreateTimer.toggle()
                                            } else {
                                                showPremium = true
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 12))
                                                Text("Add")
                                                    .font(.system(size: 14))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color("buttonColor").cornerRadius(100))
                                            .foregroundColor(Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)))
                                        }
                                    }.padding(.top, 10)
                                    TimerList()
                                }
                            }
                        }.padding(20)
                    } else {
                        TimerView()
                        if !entitlementManager.hasPro {
                            Rectangle()
                                .frame(width: 1, height: 80)
                                .foregroundStyle(.clear)
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if countDownIsOn == false && countUpisOn == false {
                            withAnimation {
                                if value.predictedEndTranslation.width > 0 {
                                    countUpViewModel.changeTimerTab(selectedTab: .countUp)
                                } else {
                                    countUpViewModel.changeTimerTab(selectedTab: .countDown)
                                }
                            }
                        }
                    }
            )
            .sheet(isPresented: $showCreateTimer) {
                CreateTimer(showCreateTimer: $showCreateTimer)
                    .presentationDetents([.height(120)])
            }
            .sheet(isPresented: $showCreateCalendar) {
                NavigationStack {
                    CreateEventView(title: Binding(
                        get: { getTimerItemById(id: timerID!).first?.title ?? quickTimerName },
                        set: { newValue in getTimerItemById(id: timerID!).first?.title = newValue }
                    ), startDate: $startTimerDate, endDate: $endDate, createDate: $createDate)
                }
            }
            .alert("Would you like to save this record?", isPresented: $showingSaveAlert) {
                Button("Save", action: {
                    countUpViewModel.stopTimer()
                    showCreateCalendar.toggle()
                })
                Button("Delete", role: .destructive, action: {
                    countUpViewModel.stopTimer()
                    timerID = UUID()
                    quickTimerName = ""
                })
            }
            .alert("Quick Timer", isPresented: $showStartQuickTimer, actions: {
                TextField("Title", text: $quickTimerName)
                Button("Start", action: {
                    startTimerDate = Date()
                    countUpViewModel.startTimer()
                    showWidget.showCountUpWidget(title: quickTimerName, icon: "clock", startTimerDate: startTimerDate)
                })
                Button("Cancel", role: .cancel, action: {
                    quickTimerName = ""
                })
            }, message: {
                Text("Please enter your event name.")
            })
            .navigationTitle("Timer List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                if countDownIsOn == false && countUpisOn == false {
                    if !appBlockAuthority {
                        Task {
                            await authorize()
                        }
                    } else {
                        isShowingAppPicker.toggle()
                    }
                }
            }, label: {
                HStack {
                    Image(systemName: "square.stack.3d.up.fill")
                    Text(String(blockAppSelecton.applications.count))
                }
                .foregroundColor(Color("todayBackground"))
                .font(.system(size: 12))
                .opacity(countDownIsOn == false && countUpisOn == false ? 1 : 0.6)
            }))
            .fullScreenCover(isPresented: $showPremium) {
                PremiumView()
            }
            .familyActivityPicker(isPresented: $isShowingAppPicker, selection: $blockAppSelecton)
        }
    }
    private func getTimerItemById(id: UUID) -> FetchedResults<TimerItem> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        timerItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return timerItems
    }
    private func authorize() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            appBlockAuthority = true
        } catch {
            appBlockAuthority = false
        }
    }
}
extension UUID: RawRepresentable {
    public var rawValue: String {
        self.uuidString
    }
    public typealias RawValue = String
    public init?(rawValue: RawValue) {
        self.init(uuidString: rawValue)
    }
}
