//
//  CreateTimer.swift
//  LifeLog
//
//  Created by Genki on 10/31/23.
//

import SwiftUI
import SymbolPicker

struct CreateTimer: View {
    @Environment(\.managedObjectContext) var viewContext
    @State private var iconPickerPresented = false
    @State private var icon = "pencil"
    @State var title = ""
    @FocusState private var focused: Bool
    @Binding var showCreateTimer: Bool
    var body: some View {
        GeometryReader { _ in
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            addTimerEvent(title: title, icon: icon)
                            showCreateTimer.toggle()
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
    func addTimerEvent(title: String, icon: String) {
        let newTimerEvent = TimerItem(context: viewContext)
        newTimerEvent.title = title
        newTimerEvent.icon = icon
        newTimerEvent.id = UUID()
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

struct CreateTimer_Previews: PreviewProvider {
    @State static var showCreateTimer = false
    static var previews: some View {
        CreateTimer(showCreateTimer: $showCreateTimer)
    }
}
