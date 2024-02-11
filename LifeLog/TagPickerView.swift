//
//  calendarPicker.swift
//  LifeLog
//
//  Created by Genki on 11/10/23.
//

import SwiftUI
import CoreData

struct TagPickerView: View {
    @State private var showCreateCalendarType = false
    @State private var showCalendarTypeMenu = false
    @State private var edit = false
    @State private var title = ""
    @State private var color: Color = .purple
    @State private var id = UUID()
    @Binding var calendarColor: Color
    @Binding var calendarName: String
    @Binding var calendarID: UUID
    @FetchRequest(sortDescriptors: [SortDescriptor(\EventTag.name)]) var tag: FetchedResults<EventTag>
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(tag) { calendar in
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(convertDataToColor(data: calendar.color!))
                                .font(.system(size: 12))
                            Text(calendar.name!)
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            calendarColor = convertDataToColor(data: calendar.color!)!
                            calendarName = calendar.name!
                            calendarID = calendar.id!
                            dismiss()
                        }
                    }
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
                    .onTapGesture {
                        showCreateCalendarType.toggle()
                    }
                    HStack {
                        Spacer()
                        Button {
                            showCalendarTypeMenu.toggle()
                        } label: {
                            HStack {
                                Text("Edit Tag")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(Color("textColorPurple"))
                        }
                    }.padding()
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle("Tag")
            }
        }
        .sheet(isPresented: $showCreateCalendarType) {
            EditTag(title: $title, selectColor: $color, id: $id, edit: $edit)
        }
        .sheet(isPresented: $showCalendarTypeMenu) {
            TagMenuView()
        }
    }
}
