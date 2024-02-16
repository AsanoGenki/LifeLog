//
//  TimerList.swift
//  LifeLog
//
//  Created by Genki on 10/31/23.
//

import SwiftUI
import CoreData
import SwipeableView

struct TimerList: View {
    @EnvironmentObject var countUpViewModel: CountUpTimerViewModel
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var timerItems: FetchedResults<TimerItem>
    @State var title = "timerTitle"
    @State var icon = "pencil"
    @State var id = UUID()
    @State var showEditTimer = false
    @AppStorage("timerID") var timerID: UUID?
    @AppStorage("startDate") var startTimerDate = Date()
    let showWidget = WidgetController()
    let container = SwManager()
    let userdefaults = UserDefaults(suiteName: "group.com.DeviceActivityMonitorExtension")
    var body: some View {
        ForEach(timerItems, id: \.self) { timerItem in
            if timerItem.title?.isEmpty == false && timerItem.icon?.isEmpty == false && timerItem.id != nil {
                    SwipeableView(content: {
                        ZStack {
                            Color("whiteBlack")
                            HStack(spacing: 10) {
                                Image(systemName: timerItem.icon!)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color("iconColor"))
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(timerItem.title!)
                                        .font(.system(size: 20))
                                }
                                Spacer()
                                Image(systemName: "arrowtriangle.forward.fill")
                                    .foregroundColor(Color("iconColor"))
                                    .frame(width: 36)
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(maxHeight: .infinity)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("borderColor"), lineWidth: 0.5)
                        )
                        .onTapGesture {
                            userdefaults!.set(timerItem.title, forKey: "countUpTimer")
                            countUpViewModel.startTimer()
                            timerID = timerItem.id
                            startTimerDate = Date()
                            showWidget.showCountUpWidget(
                                title: timerItem.title!,
                                icon: timerItem.icon!,
                                startTimerDate: startTimerDate
                            )
                        }
                    },
                                  leftActions: [Action(title: "Delete", iconName: "trash", bgColor: .red, action: {
                        deleteTimerEvent(event: timerItem)
                    }
                                                      )],
                                  rightActions: [Action(title: "Edit", iconName: "pencil", bgColor: .blue, action: {
                        title = timerItem.title!
                        icon = timerItem.icon!
                        id = timerItem.id!
                        showEditTimer.toggle()
                        return nil
                    })],
                                  rounded: true,
                                  container: container)
                    .frame(height: 70)
                    .sheet(isPresented: $showEditTimer) {
                        EditTimer(
                            icon: $icon,
                            title: $title,
                            id: $id,
                            showEditTimer: $showEditTimer,
                            timerItem: timerItem)
                            .presentationDetents([.height(120)])
                    }
                }
        }
    }
    func deleteTimerEvent(event: FetchedResults<TimerItem>.Element) {
        viewContext.delete(event)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

func intToTimeString(time: Int) -> String {
    let hours = time / 60
    let minutes = (time % 3600) % 60
    let minuteStamp = String(String(minutes).count > 1 ? String(minutes) : "0" + String(minutes))
    let result = "\(hours)h \(minuteStamp)m"
    return result
}
