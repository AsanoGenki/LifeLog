//
//  EditCalendarType.swift
//  LifeLog
//
//  Created by Genki on 11/10/23.
//

import SwiftUI
import CoreData

struct EditTag: View {
    @State private var showActionSheet = false
    @State private var showingAlert = false
    @State private var showEventItemList = false
    @State private var tagName = ""
    @Binding var title: String
    @Binding var selectColor: Color
    @Binding var id: UUID
    @Binding var edit: Bool
    @FetchRequest(sortDescriptors: []) var tag: FetchedResults<EventTag>
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\CalendarItem.startDate, order: .reverse)
    ]) var calendarItem: FetchedResults<CalendarItem>
    @FetchRequest(sortDescriptors: [])
    var deleteCalendarItems: FetchedResults<CalendarItem>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @AppStorage("defaultTagID") var defaultTagID: UUID = UUID()
    let colors: [Color] = [.red, .pink, .orange, .yellow, .green, .mint, .cyan, .blue, .indigo, .purple, .brown, .gray]
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 6)
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 5) {
                    Image(systemName: "circle.fill")
                        .foregroundColor(selectColor)
                        .font(.system(size: 12))
                    TextField("Title", text: $title)
                        .font(.system(size: 26))
                        .fontWeight(.medium)
                        .onChange(of: title) { newValue in
                            title = newValue
                        }
                }
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(colors, id: \.self) { color in
                        ZStack {
                            Circle()
                                .foregroundColor(color)
                                .frame(width: 30, height: 30)
                            if color == selectColor {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                                    .fontWeight(.medium)
                            }
                        }.onTapGesture {
                            selectColor = color
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                if edit {
                    Button {
                        if let name = getCalendarTypeById(id: id).first?.name {
                            tagName = name
                        }
                        DispatchQueue.main.async {
                            showEventItemList.toggle()
                        }
                    } label: {
                        HStack {
                            Text("\(getCalendarItem().count) Events")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                Spacer()
                if edit {
                    Text("Delete Tag")
                        .foregroundStyle(.red)
                        .onTapGesture {
                            if defaultTagID != id {
                                showActionSheet.toggle()
                            } else {
                                showingAlert.toggle()
                            }
                        }
                }
            }
            .padding()
            .alert("Default Tag cannot be deleted", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Are you sure you want to delete this calendar? All events associated with the calendar also be deleted."),
                    buttons: [
                        .cancel(),
                        .destructive(
                            Text("Delete Tag"),
                            action: {
                                deleteCalendarItemByTypeID(events: getCalendarItemByTypeID(id: id))
                                if let event = getCalendarTypeById(id: id).first {
                                    deleteCalendarType(event: event)
                                }
                                dismiss()
                            }
                        )
                    ]
                )
            }
            .sheet(isPresented: $showEventItemList) {
                EventItemListByTag(tagName: $tagName, calendarItem: getCalendarItem())
            }
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }, label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }), trailing: Button(action: {
                if edit {
                    if let item = getCalendarTypeById(id: id).first {
                        editCalendarType(event: item)
                    }
                } else {
                    addCalendarType()
                }
                dismiss()
            }, label: {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }))
        }
    }
    private func deleteCalendarType(event: FetchedResults<EventTag>.Element) {
        viewContext.delete(event)
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    private func deleteCalendarItemByTypeID(events: FetchedResults<CalendarItem>) {
        for event in events {
            viewContext.delete(event)
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("\(error)")
        }
    }
    private func getCalendarItemByTypeID(id: UUID) -> FetchedResults<CalendarItem> {
        let predicate = NSPredicate(format: "tag.id == %@", id as CVarArg)
        deleteCalendarItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return deleteCalendarItems
    }
    private func addCalendarType() {
        let newItem = EventTag(context: viewContext)
        newItem.name = title
        newItem.color = convertColorToData(color: selectColor)
        newItem.id = UUID()
        newItem.show = true
                do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func editCalendarType(event: FetchedResults<EventTag>.Element) {
        event.name = title
        event.color = convertColorToData(color: selectColor)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    private func getCalendarTypeById(id: UUID) -> FetchedResults<EventTag> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        tag.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return tag
    }
    private func getCalendarItem() -> FetchedResults<CalendarItem> {
        let predicate = NSPredicate(format: "tag.id == %@", id as UUID as CVarArg)
        calendarItem.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        return calendarItem
    }
}

struct EditCalendarType_Previews: PreviewProvider {
    @State static var title = "Tag"
    @State static var selectColor: Color = .purple
    @State static var edit = true
    @State static var id = UUID()
    static var previews: some View {
        EditTag(title: $title, selectColor: $selectColor, id: $id, edit: $edit)
    }
}
