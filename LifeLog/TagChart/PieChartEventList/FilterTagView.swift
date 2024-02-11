//
//  FilterTagView.swift
//  LifeLog
//
//  Created by Genki on 1/26/24.
//

import SwiftUI
import CoreData

struct FilterTagView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\EventTag.name)]) var tag: FetchedResults<EventTag>
    @State var showCreateCalendarType = false
    @State var showCalendarTypeMenu = false
    @State var edit = false
    @State var title = ""
    @State var color: Color = .purple
    @State var id = UUID()
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PieChartViewModel
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Image(systemName: "tag")
                            .font(.system(size: 12))
                        Text("All")
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        viewModel.changeFilterTag(uuid: nil)
                        dismiss()
                    }
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
                            viewModel.changeFilterTag(uuid: calendar.id!)
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
