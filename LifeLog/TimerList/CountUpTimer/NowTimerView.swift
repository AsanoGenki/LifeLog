//
//  nowTimerView.swift
//  LifeLog
//
//  Created by Genki on 11/12/23.
//

import SwiftUI
import CoreData

struct NowTimerView: View {
    @EnvironmentObject var countUpViewModel: CountUpTimerViewModel
    @FetchRequest(sortDescriptors: []) var timerItem: FetchedResults<TimerItem>
    @AppStorage("timerID") var timerID: UUID?
    @AppStorage("quickTimerName") var quickTimerName: String = ""
    @Binding var showingSaveAlert: Bool
    @Binding var endDate: Date
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if let item = getTimerItemById(id: timerID!).first {
                        Image(systemName: item.icon!)
                            .font(.system(size: 24))
                            .foregroundColor(Color("iconColor"))
                            .frame(width: 36)
                        Text(item.title!)
                    } else {
                        Image(systemName: "clock")
                            .font(.system(size: 24))
                            .foregroundColor(Color("iconColor"))
                            .frame(width: 36)
                        Text(quickTimerName == "" ? "Timer" : quickTimerName)
                    }
                }
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 24))
                        .foregroundColor(Color("iconColor"))
                        .frame(width: 36)
                    Text(intToStringTime(count: countUpViewModel.elapsedTime))
                        .font(.system(size: 42).monospacedDigit())
                }
            }
                Spacer()
                Button {
                    endDate = Date()
                    showingSaveAlert.toggle()
                } label: {
                    Text("Stop")
                        .font(.system(size: 12))
                        .frame(width: 56, height: 56)
                        .background(Color("buttonColor"))
                        .foregroundColor(Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1)))
                        .clipShape(Circle())
                }.font(.system(size: 50))
            }
        .padding(20)
        .frame(maxHeight: .infinity)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("borderColor"), lineWidth: 0.5)
        )
        }
    func getTimerItemById(id: UUID) -> FetchedResults<TimerItem> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        timerItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return timerItem
    }
}
func intToStringTime(count: Int) -> String {
    let hours = count / 3600
    let hoursStamp = String(hours < 1 ? "" : String("\(hours):"))
    let minutes = (count % 3600) / 60
    let minuteStamp = String(String(minutes).count > 1 ? String(minutes) : "0" + String(minutes))
    let secound = (count % 3600) % 60
    let secoundStamp = String(String(secound).count > 1 ? String(secound) : "0" + String(secound))
    let result = "\(hoursStamp)\(minuteStamp):\(secoundStamp)"
    return result
}
