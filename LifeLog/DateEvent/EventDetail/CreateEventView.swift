//
//  EditCalendarView.swift
//  YourTime
//
//  Created by Genki on 10/28/23.
//

import SwiftUI
import Combine
import EventKit
import CoreData

struct CreateEventView: View {
    @Binding var title: String
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var createDate: UUID
    @State private var fulfillment: Double = 50.0
    @State private var calendarColor: Color = .purple
    @State private var calendarID: UUID = UUID()
    @State private var calendarName: String = "Calendar"
    @State private var date = Date()
    @State private var isShowAlert = false
    @State private var memo = ""
    @State private var showCalendarPicker = false
    @State private var useFulfillment = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.requestReview) var requestReview
    @AppStorage("defaultTagID") var defaultTagID: UUID = UUID()
    @AppStorage("reviewRequestCount") var reviewRequestCount = 0
    @AppStorage("requestDate") var requestDate = Date()
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    @FetchRequest(sortDescriptors: []) var calendarItem: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var tag: FetchedResults<EventTag>
    @FetchRequest(sortDescriptors: []) var requestCalendarItem: FetchedResults<CalendarItem>
    @FocusState private var focused: Bool
    @FocusState private var memoFocused: Bool
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack(alignment: .top) {
                        Rectangle()
                            .frame(width: 3, height: 20)
                            .cornerRadius(100)
                            .foregroundColor(calendarColor)
                            .padding(.top, 6)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $title)
                                .focused($focused)
                                .submitLabel(.done)
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                                .onReceive(title.publisher.last()) { value in
                                    if value == "\n" {
                                        focused = false
                                        if !title.isEmpty {
                                            title.removeLast()
                                        }
                                    }
                                }
                                .onChange(of: title) { value in
                                    if value.contains("\n") {
                                        title = value.replacingOccurrences(of: "\n", with: "")
                                        self.dismissKeyboard()
                                    }
                                }
                            Text(title).opacity(0).padding(.all, 8)
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                            if title.isEmpty {
                                Text("Title") .foregroundColor(Color(uiColor: .placeholderText))
                                    .padding(.vertical, 8)
                                    .padding(.leading, 8)
                                    .fontWeight(.medium)
                                    .font(.system(size: 24))
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.vertical, -6)
                        Spacer()
                    }
                }.listRowSeparator(.hidden)
                    .padding(.vertical, 6)
                    .padding(.bottom, 8)
                Section {
                    EventTimeEditView(startDate: $startDate, endDate: $endDate)
                    HStack {
                        Image(systemName: "face.smiling")
                            .frame(width: 20, alignment: .leading)
                        HStack {
                            Text("FulFillment")
                            if useFulfillment {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("iconColor"))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color("iconColor"))
                            }
                        }.onTapGesture {
                            useFulfillment.toggle()
                        }
                        Spacer()
                        HStack(spacing: 3) {
                            if useFulfillment {
                                returnFace(adequancy: Int(fulfillment))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("\(Int(fulfillment))")
                                    .font(.system(size: 14))
                                    .frame(width: 26)
                            } else {
                                Image("noFace")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("-")
                                    .font(.system(size: 14))
                                    .frame(width: 26)
                            }
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }.padding(.top, 10)
                    if useFulfillment {
                        Slider(value: $fulfillment,
                               in: 0...100)
                        .accentColor(Color("iconColor"))
                    }
                    HStack {
                        Image(systemName: "tag")
                            .frame(width: 20, alignment: .leading)
                        Text("Tag")
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(calendarColor)
                                .font(.system(size: 10))
                            Text(calendarName)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            showCalendarPicker.toggle()
                        }
                    }
                    VStack {
                        HStack {
                            Image(systemName: "note")
                                .frame(width: 20, alignment: .leading)
                            Text("Memo")
                            Spacer()
                        }
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $memo)
                                .focused($memoFocused)
                                .submitLabel(.done)
                                .onReceive(memo.publisher.last()) { value in
                                    if value == "\n" {
                                        memoFocused = false
                                        if !memo.isEmpty {
                                            memo.removeLast()
                                        }
                                    }
                                }
                                .onChange(of: memo) { value in
                                    if value.contains("\n") {
                                        memo = value.replacingOccurrences(of: "\n", with: "")
                                        self.dismissKeyboard()
                                    }
                                }
                            Text(memo).opacity(0).padding(.all, 8)
                            if memo.isEmpty {
                                Text("Enter your memo here") .foregroundColor(Color(uiColor: .placeholderText))
                                    .padding(.vertical, 8)
                                    .padding(.leading, 8)
                                    .allowsHitTesting(false)
                            }
                        }.padding(.vertical, -6)
                    }
                    Rectangle()
                        .frame(width: 10, height: 100)
                        .foregroundColor(.clear)
                }.listRowSeparator(.hidden)
            }
            .onAppear {
                if let item = getCalendarTypeById(id: defaultTagID).first {
                    calendarName = item.name!
                    calendarColor = convertDataToColor(data: item.color!)!
                    calendarID = item.id!
                }
            }
            .alert("Cannot Save Event", isPresented: $isShowAlert) {
            } message: {
                Text("The start date must be before the end date.")
            }
            .listStyle(.inset)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }, label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }), trailing: Button(action: {
                if title != "" {
                    if startDate < endDate {
                        addEvent(title: title, startDate: startDate, endDate: endDate,
                                 adequancy: useFulfillment ? Int16(fulfillment) : -1, memo: memo)
                        createDate = UUID()
                        if let dateItem = getDateItem(date: startDate)?.first {
                            editDateItem(event: dateItem)
                        } else {
                            addDateItem()
                        }
                        dismiss()
                    } else {
                        isShowAlert = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        requestReviewMethod()
                    }
                }
            }, label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundColor(title != "" ? .primary : Color(UIColor.placeholderText))
            }))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            self.focused = false
                            memoFocused = false
                        }
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focused = true
            }
            UIDatePicker.appearance().minuteInterval = 5
        }
        .sheet(isPresented: $showCalendarPicker) {
            TagPickerView(calendarColor: $calendarColor, calendarName: $calendarName, calendarID: $calendarID)
        }
    }
}

extension CreateEventView {
    private func addEvent(title: String, startDate: Date, endDate: Date, adequancy: Int16, memo: String) {
        let newEvent = CalendarItem(context: viewContext)
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.adequancy = adequancy
        newEvent.memo = memo
        newEvent.id = UUID()
        newEvent.tag = getCalendarTypeById(id: calendarID).first
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    private func addDateItem() {
        let newItem = DateItem(context: viewContext)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: startDate)
        if let newDate = calendar.date(from: components) {
            date = newDate
        }
        newItem.date = date
        newItem.dialy = ""
        newItem.images = nil
        newItem.adequancy = Int16(fulfillment)
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func editDateItem(event: FetchedResults<DateItem>.Element) {
        var dateItemAdequancy = 0.0
        dateItemAdequancy = calculateAveragePoints(eventItems: getCalendarItem(date: startDate))
        event.adequancy = Int16(round(dateItemAdequancy))
        self.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func calculateAveragePoints(eventItems: FetchedResults<CalendarItem>) -> Double {
        var totalPoints = 0.0
        var totalDuration = 0.0
        for eventItem in eventItems {
            if let eventStartDate = eventItem.startDate, let eventEndDate = eventItem.endDate {
                let duration = eventEndDate.timeIntervalSince(eventStartDate) / 3600 // convert to hours
                totalPoints += Double(eventItem.adequancy) * duration
                totalDuration += duration
            }
        }
        return totalPoints / totalDuration
    }
    private func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItem.nsPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [predicate])
        return calendarItem
    }
    private func getDateItem(date: Date) -> FetchedResults<DateItem>? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let predicate = NSPredicate(format: "(%@ <= date) AND (date <= %@)", targetDate as NSDate, targetDate as NSDate)
        dateItem.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return dateItem
    }
    private func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
    private func requestReviewMethod() {
        if reviewRequestCount == 0 {
            if getRequestCalendarItem().count > 10 {
                requestReview()
                reviewRequestCount += 1
                requestDate = Date()
            }
        } else if reviewRequestCount == 1 {
            if getRequestCalendarItem().count > 30 &&
                requestDate < Calendar.current.date(byAdding: .day, value: -3, to: Date())! {
                requestReview()
                reviewRequestCount += 1
                requestDate = Date()
            }
        } else if reviewRequestCount == 2 {
            if getRequestCalendarItem().count > 50 &&
                requestDate < Calendar.current.date(byAdding: .day, value: -7, to: Date())! {
                requestReview()
                reviewRequestCount += 1
            }
        }
    }
    private func getRequestCalendarItem() -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let endDate = Date()
        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        let predicate2 = NSPredicate(format: "tag.show == true")
        requestCalendarItem.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        return requestCalendarItem
    }
}
