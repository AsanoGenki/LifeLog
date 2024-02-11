//
//  InputFullfilment.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI
import CoreData

struct InputFullfilment: View {
    @Binding var title: String
    @Binding var detail: String
    @State private var fullfilment = 0
    @State private var resultFullfilment = 0
    @State private var number = 50.0
    @State private var date = Date()
    @Environment(\.managedObjectContext) var viewContext
    @State private var showResult = false
    @State private var calendarID: UUID = UUID()
    @FetchRequest(sortDescriptors: []) private var tag: FetchedResults<EventTag>
    @FetchRequest(sortDescriptors: []) private var dateItem: FetchedResults<DateItem>
    @FetchRequest(sortDescriptors: []) private var allDateItem: FetchedResults<DateItem>
    @FetchRequest(sortDescriptors: []) private var calendarItem: FetchedResults<CalendarItem>
    @State private var endDate = Date()
    @State private var loading = false
    @AppStorage("imageData") var imageData = 0.0
    @AppStorage("defaultTagID") var defaultTagID: UUID = UUID()
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(
                    colors: [
                        .white,
                        Color(hue: 1 - (number / 120), saturation: 1, brightness: 1).opacity(0.7)]),
                center: .center,
                startRadius: 60,
                endRadius: 650
            )
            .ignoresSafeArea(.all)
            VStack {
                Text("Choose your \nlevel of satisfaction\nwith the activity")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32))
                    .bold()
                    .padding(.top, 60)
                    .foregroundColor(Color(hue: 1 - (number / 120), saturation: 1, brightness: 0.4))
                Spacer()
            }
            VStack {
                Spacer()
                VStack {
                    returnFace(adequancy: Int(number))
                        .resizable()
                        .frame(width: 130, height: 130)
                    VStack(spacing: 5) {
                        Text(returnFullfilment(fullfilment: Int(number)))
                            .font(.system(size: 32))
                            .bold()
                            .foregroundColor(Color(hue: 1 - (number / 120), saturation: 1, brightness: 0.4))
                        Text("\(Int(number))")
                            .font(.system(size: 32))
                            .bold()
                            .padding(.bottom, 20)
                            .foregroundColor(Color(hue: 1 - (number / 120), saturation: 1, brightness: 0.4))
                    }
                }
                Spacer()
            }
            VStack {
                EmotionSlider(value: $number, in: 0...100, step: 1.0)
                HStack {
                    Text("VERY DISSSATISFIED")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hue: 1 - (number / 120), saturation: 1, brightness: 0.4))
                    Spacer()
                    Text("VERY SATISFIED")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hue: 1 - (number / 120), saturation: 1, brightness: 0.4))
                        .padding(.top, 3)
                }.padding(.bottom, 20)
                Button {
                    loading = true
                    fullfilment = Int(number)
                    resultFullfilment = Int(number)
                    addEvent(title: title, adequancy: Int16(fullfilment), id: UUID(), memo: detail)
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
                    if let dateItem = getDateItem(date: date)?.first {
                        editDateItem(event: dateItem)
                    } else {
                        addDateItem()
                    }
                    calculateImageCapacity()
                    loading = false
                    showResult = true
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, maxHeight: 48)
                        .background(
                            Color(hue: 1 - (number / 120),
                                  saturation: 1,
                                  brightness: 0.6).cornerRadius(100)
                        )
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            if loading {
                ProgressView("Now Loading")
            }
        }
        .onAppear {
            if let item = tag.first {
                calendarID = item.id!
                defaultTagID = item.id!
            } else {
                let calendar = EventTag(context: self.viewContext)
                calendar.name = "Tag 1"
                calendar.color = convertColorToData(color: .purple)
                calendar.id = UUID()
                calendarID = calendar.id!
                defaultTagID = calendar.id!
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            ResultView(title: $title, detail: $detail, fullfilment: $resultFullfilment, endDate: $endDate)
        }
    }
    private func addEvent(title: String, adequancy: Int16, id: UUID, memo: String) {
        let newEvent = CalendarItem(context: viewContext)
        newEvent.title = title
        newEvent.startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())
        newEvent.endDate = Date()
        newEvent.adequancy = adequancy
        newEvent.memo = memo
        newEvent.id = id
        newEvent.tag = getCalendarTypeById(id: calendarID).first
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    private func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
    func getDateItem(date: Date) -> FetchedResults<DateItem>? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let predicate = NSPredicate(format: "(%@ <= date) AND (date <= %@)", targetDate as NSDate, targetDate as NSDate)
        dateItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return dateItem
    }
    private func addDateItem() {
        let newItem = DateItem(context: viewContext)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let newDate = calendar.date(from: components) {
            date = newDate
        }
        newItem.date = date
        newItem.dialy = ""
        newItem.images = nil
        newItem.adequancy = Int16(fullfilment)
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func editDateItem(event: FetchedResults<DateItem>.Element) {
        var totalAdequancy = 0
        for item in getCalendarItem(date: date) {
            totalAdequancy += Int(item.adequancy)
        }
        fullfilment = Int(Double(totalAdequancy / getCalendarItem(date: date).count))
        event.adequancy = Int16(fullfilment)
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(
            format: "(%@ <= startDate) AND (startDate <= %@)",
            startDate as NSDate,
            endDate as NSDate
        )
        calendarItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return calendarItem
    }
    private func calculateImageCapacity() {
        imageData = 0
        for item in allDateItem {
            if let images = imagesFromCoreData(object: item.images) {
                for image in images {
                    if let data = image.jpegData(compressionQuality: 1.0) {
                        let imageSizeInMB = Double(data.count) / 1024.0 / 1024.0
                        imageData += imageSizeInMB
                    }
                }
            }
        }
    }
}
struct InputFullfilment_Previews: PreviewProvider {
    @State static var title = ""
    @State static var detail = ""
    static var previews: some View {
        InputFullfilment(title: $title, detail: $detail)
    }
}
