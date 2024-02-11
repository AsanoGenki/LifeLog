//
//  EditCalendarType.swift
//  LifeLog
//
//  Created by Genki on 11/10/23.
//

import SwiftUI

struct TagMenuView: View {
    @State private var showEditCalendarType = false
    @State private var edit = true
    @State private var title = ""
    @State private var color: Color = .purple
    @State private var id = UUID()
    @State private var savedCalendar: [UUID] = []
    @FetchRequest(sortDescriptors: [SortDescriptor(\EventTag.name)]) var tag: FetchedResults<EventTag>
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        if tag.allSatisfy({ $0.show }) {
                            Text("HIDE ALL")
                                .font(.system(size: 14))
                                .onTapGesture {
                                    for type in tag {
                                        type.show = false
                                    }
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        fatalError("セーブに失敗")
                                    }
                                }
                        } else {
                            Text("SHOW ALL")
                                .font(.system(size: 14))
                                .onTapGesture {
                                    for type in tag {
                                        type.show = true
                                    }
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        fatalError("セーブに失敗")
                                    }
                                }
                        }
                    }
                    ForEach(tag) { calendar in
                        HStack {
                            if calendar.show == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(convertDataToColor(data: calendar.color!))
                                    .font(.system(size: 16))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(convertDataToColor(data: calendar.color!))
                                    .font(.system(size: 16))
                            }
                            Text(calendar.name!)
                            Spacer()
                            Image(systemName: "info.circle")
                                .onTapGesture {
                                    if let calendarName = calendar.name,
                                       let calendarColor = calendar.color,
                                       let calendarId = calendar.id {
                                        DispatchQueue.main.async {
                                            title = calendarName
                                            if let convertedColor = convertDataToColor(data: calendarColor) {
                                                color = convertedColor
                                            }
                                            id = calendarId
                                            edit = true
                                        }
                                        showEditCalendarType = true
                                    } else {
                                    }
                                    }
                        }
                        .padding()
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            if calendar.show == false {
                                calendar.show = true
                                do {
                                    try viewContext.save()
                                } catch {
                                    fatalError("セーブに失敗")
                                }
                            } else {
                                calendar.show = false
                                do {
                                    try viewContext.save()
                                } catch {
                                    fatalError("セーブに失敗")
                                }
                            }
                        }
                    }
                    Button {
                        DispatchQueue.main.async {
                            title = ""
                            color = .purple
                            edit = false
                        }
                        showEditCalendarType = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                            Text("New Tag")
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 10)
                    }
                    .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .sheet(isPresented: $showEditCalendarType) {
                    EditTag(title: $title, selectColor: $color, id: $id, edit: $edit)
                }
                .navigationTitle("Edit Tag")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    TagMenuView()
}
