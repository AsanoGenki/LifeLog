//
//  EditTimer.swift
//  LifeLog
//
//  Created by Genki on 10/31/23.
//

import SwiftUI
import SymbolPicker
import CoreData

struct EditTimer: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var iconPickerPresented = false
    @Binding var icon: String
    @Binding var title: String
    @Binding var id: UUID
    @FocusState private var focused: Bool
    @Binding var showEditTimer: Bool
    @ObservedObject var timerItem: TimerItem
    @FetchRequest(sortDescriptors: []) var timerItems: FetchedResults<TimerItem>
    var body: some View {
        GeometryReader { _ in
            VStack {
                HStack {
                    Spacer()
                    Button {
                        editTimerItem(id: id, title: title, icon: icon)
                        showEditTimer.toggle()
                    } label: {
                        Text("Save")
                            .foregroundColor(Color("iconColor"))
                    }
                }
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(Color("iconColor"))
                        .onTapGesture {
                            iconPickerPresented.toggle()
                        }
                    TextField("Title", text: $title)
                        .font(.system(size: 30).bold())
                        .focused($focused)
                }
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    focused = true
                }
            }
            .padding()
            .padding(.top, 10)
            .sheet(isPresented: $iconPickerPresented) {
                SymbolPicker(symbol: $icon)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    func editTimerItem(id: UUID, title: String, icon: String) {
        if let event = gettimerItemById(id: id).first {
            event.title = title
            event.icon = icon
            do {
                try viewContext.save()
            } catch {
            }
        }
    }
    func gettimerItemById(id: UUID) -> FetchedResults<TimerItem> {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        timerItems.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate])
        return timerItems
    }
}
