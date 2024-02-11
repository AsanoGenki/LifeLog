//
//  InputEventTitle.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI

struct InputEventTitle: View {
    @State private var title = ""
    @State private var detail = ""
    @FocusState private var focused: Bool
    @FocusState private var detailFocused: Bool
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section {
                        HStack {
                            Text("Let's write down what you've\nbeen doing in the last hour.")
                                .font(.system(size: 23))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        VStack {
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
                            Divider()
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $detail)
                                    .focused($focused)
                                    .submitLabel(.done)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .onReceive(detail.publisher.last()) { value in
                                        if value == "\n" {
                                            focused = false
                                            if !detail.isEmpty {
                                                detail.removeLast()
                                            }
                                        }
                                    }
                                    .onChange(of: detail) { value in
                                        if value.contains("\n") {
                                            detail = value.replacingOccurrences(of: "\n", with: "")
                                            self.dismissKeyboard()
                                        }
                                    }
                                Text(detail).opacity(0).padding(.all, 8)
                                    .font(.system(size: 24))
                                    .fontWeight(.medium)
                                if detail.isEmpty {
                                    Text("Detail") .foregroundColor(Color(uiColor: .placeholderText))
                                        .padding(.vertical, 8)
                                        .padding(.leading, 8)
                                        .fontWeight(.medium)
                                        .font(.system(size: 16))
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }.listStyle(.inset)
                Spacer()
                if !focused {
                    NavigationLink(destination: InputFullfilment(title: $title, detail: $detail)) {
                        Text("Next")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(
                                title != "" ?
                                Color.blue.opacity(0.8).cornerRadius(10) :
                                    Color.black.opacity(0.4).cornerRadius(10)
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }.disabled(title == "")
                }
            }
            if focused {
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            Spacer()
                            Button {
                                focused = false
                            } label: {
                                Text("Done")
                                    .font(.system(size: 18))
                                    .padding(12)
                                    .padding(.horizontal, 8)
                                    .foregroundColor(.blue)
                            }
                        }.background(Color(UIColor.quaternarySystemFill))
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    InputEventTitle()
}
