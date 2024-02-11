//
//  EditCalendarView.swift
//  LifeLog
//
//  Created by Genki on 11/1/23.
//

import SwiftUI
import Combine
import EventKit
import CoreData

struct EditEventView: View {
    @State private var calendarColor: Color = .purple
    @State private var calendarName: String = "Purple"
    @State private var isShowAlert = false
    @State private var showActionSheet = false
    @State private var showCalendarPicker = false
    @State private var useAdequancy = true
    @Binding var adequancy: Double
    @Binding var calendarID: UUID
    @Binding var createDate: UUID
    @Binding var endDate: Date
    @Binding var id: UUID
    @Binding var memo: String
    @Binding var startDate: Date
    @Binding var title: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var calendarItems: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: []) var dateItem: FetchedResults<DateItem>
    @FetchRequest(sortDescriptors: []) var tag: FetchedResults<EventTag>
    @FocusState private var focused: Bool
    @FocusState private var memoFocused: Bool
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 3, height: 20)
                                .cornerRadius(100)
                                .foregroundColor(calendarColor)
                                .padding(.top, 7)
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
                        .padding(.vertical, 10)
                        .padding(.bottom, 8)
                    Section {
                        EventTimeEditView(startDate: $startDate, endDate: $endDate)
                        HStack {
                            Image(systemName: "face.smiling")
                                .frame(width: 20, alignment: .leading)
                            HStack {
                                Text("FulFillment")
                                if useAdequancy {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("iconColor"))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color("iconColor"))
                                }
                            }.onTapGesture {
                                useAdequancy.toggle()
                            }
                            Spacer()
                            HStack(spacing: 3) {
                                if useAdequancy {
                                    returnFace(adequancy: Int(adequancy))
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("\(Int(adequancy))")
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
                        if useAdequancy {
                            Slider(value: $adequancy,
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
                    if adequancy == -1 {
                        useAdequancy = false
                        adequancy = 50
                    }
                    calendarName = (getCalendarTypeById(id: calendarID).first?.name)!
                    calendarColor = convertDataToColor(data: (getCalendarTypeById(id: calendarID).first?.color)!)!
                }
                .listStyle(.inset)
                if !focused && !memoFocused {
                    Text("Delete Event")
                        .foregroundStyle(.red)
                        .onTapGesture {
                            showActionSheet.toggle()
                        }
                        .padding(.bottom, 13)
                }
            }
            .alert("Cannot Save Event", isPresented: $isShowAlert) {
            } message: {
                Text("The start date must be before the end date.")
            }
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }, label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }), trailing: Button(action: {
                if title != "" {
                    if startDate < endDate {
                        if let event = getCalendarItemById(id: id).first {
                            editEvent(event: event)
                        }
                        createDate = UUID()
                        if let dateItem = getDateItem(date: startDate)?.first {
                            editDateItem(event: dateItem)
                        }
                        dismiss()
                    } else {
                        isShowAlert = true
                    }
                }
            }, label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundColor(title != "" ? .primary : Color(UIColor.placeholderText))
            }))
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
        .sheet(isPresented: $showCalendarPicker) {
            TagPickerView(calendarColor: $calendarColor, calendarName: $calendarName, calendarID: $calendarID)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Are you sure you want to delete this event?"),
                        buttons: [
                            .cancel(),
                            .destructive(
                                Text("Delete Event"),
                                action: {
                                    if let event = getCalendarItemById(id: id).first {
                                        deleteEvent(event: event)
                                    }
                                    if let dateItem = getDateItem(date: startDate)?.first {
                                        editDateItem(event: dateItem)
                                    }
                                    createDate = UUID()
                                    dismiss()
                                }
                            )
                        ]
            )
        }
    }
}

extension EditEventView {
    func editEvent(event: FetchedResults<CalendarItem>.Element) {
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.memo = memo
        if useAdequancy {
            event.adequancy = Int16(adequancy)
        } else {
            event.adequancy = -1
        }
        event.tag = getCalendarTypeById(id: calendarID).first
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    func deleteEvent(event: FetchedResults<CalendarItem>.Element) {
        viewContext.delete(event)
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    func editDateItem(event: FetchedResults<DateItem>.Element) {
        var dateItemAdequancy = 0.0
        if getCalendarItem(date: startDate).count != 0 {
            dateItemAdequancy = calculateAveragePoints(eventItems: getCalendarItem(date: startDate))
            event.adequancy = Int16(round(dateItemAdequancy))
        } else if getCalendarItem(date: startDate).count == 0 {
            if getDateItem(date: startDate)?.first?.dialy == "" && getDateItem(date: startDate)?.first?.images == nil {
                viewContext.delete(event)
            } else {
                event.adequancy = -1
            }
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    func calculateAveragePoints(eventItems: FetchedResults<CalendarItem>) -> Double {
        var totalPoints = 0.0
        var totalDuration = 0.0
        for eventItem in eventItems {
            if let eventStartDate = eventItem.startDate, let eventEndDate = eventItem.endDate {
                let duration = eventEndDate.timeIntervalSince(eventStartDate) / 3600
                totalPoints += Double(eventItem.adequancy) * duration
                totalDuration += duration
            }
        }
        return totalPoints / totalDuration
    }
    func getCalendarItem(date: Date) -> FetchedResults<CalendarItem> {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        let predicate = NSPredicate(format: "(%@ <= startDate) AND (startDate <= %@)",
                                    startDate as NSDate, endDate as NSDate)
        calendarItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return calendarItems
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
    func getCalendarItemById(id: UUID) -> FetchedResults<CalendarItem> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        calendarItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return calendarItems
    }
    func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
}
