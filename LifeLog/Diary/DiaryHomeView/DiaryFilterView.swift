//
//  DiaryFilterView.swift
//  LifeLog
//
//  Created by Genki on 12/12/23.
//

import SwiftUI

struct DiaryFilterView: View {
    @State private var showStartCalendar = false
    @State private var showEndCalendar = false
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State var sDate = Date()
    @State var eDate = Date()
    @Binding var selectedSort: Int
    @State var selectSort = 0
    @Binding var isOnFilter: Bool
    @Environment(\.dismiss) private var dismiss
    @State var defaultStartDate = Date()
    @State var defaultEndDate = Date()
    @State var showingAlert = false
    let sort = ["Recently", "Old", "High Fulfillment", "Low Fulfillment"]
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .frame(width: 20, alignment: .leading)
                        Text("Sort order")
                        Spacer()
                        Menu {
                            Button {
                                // Recently
                                selectSort = 0
                            } label: {
                                Text(LocalizedStringKey(sort[0]))
                            }
                            Button {
                                // Old
                                selectSort = 1
                            } label: {
                                Text(LocalizedStringKey(sort[1]))
                            }
                            Button {
                                // High Adequancy
                                selectSort = 2
                            } label: {
                                Text(LocalizedStringKey(sort[2]))
                            }
                            Button {
                                // Low Adequancy
                                selectSort = 3
                            } label: {
                                Text(LocalizedStringKey(sort[3]))
                            }
                        } label: {
                            Text(LocalizedStringKey(sort[selectSort]))
                                .font(.system(size: 16))
                        }
                    }
                    .onAppear {
                        selectSort = selectedSort
                        sDate = startDate
                        eDate = endDate
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.year, .month, .day], from: Date())
                        let nowDate = calendar.date(from: components)!
                        defaultStartDate = calendar.date(byAdding: .month, value: -6, to: nowDate)!
                        defaultEndDate = calendar.date(byAdding: .month, value: +6, to: nowDate)!
                    }
                        HStack {
                            Image(systemName: "clock")
                                .frame(width: 20, alignment: .leading)
                            Text("Starts")
                            Spacer()
                            Text(dateToEMMMdyyyy(sDate))
                                .font(.system(size: 14))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .foregroundColor(showStartCalendar ?
                                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1))
                                                 : .primary)
                                .background(showStartCalendar ?
                                            Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                                .cornerRadius(8)
                                .onTapGesture {
                                    withAnimation {
                                        showEndCalendar = false
                                        showStartCalendar.toggle()
                                    }
                                }
                        }
                        if showStartCalendar {
                            DatePicker(
                                "Start Date",
                                selection: $sDate,
                                displayedComponents: [.date]
                            ).datePickerStyle(.graphical)
                                .animation(.default, value: showStartCalendar)
                                .accentColor(Color(UIColor.rgba(red: 147, green: 112, blue: 219, alpha: 1)))
                        }
                        HStack {
                            Rectangle()
                                .frame(width: 20)
                                .foregroundColor(.clear)
                            Text("Ends")
                            Spacer()
                            Text(dateToEMMMdyyyy(eDate))
                                .font(.system(size: 14))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .foregroundColor(showEndCalendar ?
                                                 Color(UIColor.rgba(red: 33, green: 0, blue: 93, alpha: 1))
                                                 : .primary)
                                .background(showEndCalendar ? Color("buttonColor") : Color(UIColor.tertiarySystemFill))
                                .cornerRadius(8)
                                .onTapGesture {
                                    withAnimation {
                                        showStartCalendar = false
                                        showEndCalendar.toggle()
                                    }
                                }
                        }
                        if showEndCalendar {
                            DatePicker(
                                "Ends Date",
                                selection: $eDate,
                                displayedComponents: [.date]
                            ).datePickerStyle(.graphical)
                                .animation(.default, value: showEndCalendar)
                                .accentColor(Color(UIColor.rgba(red: 147, green: 112, blue: 219, alpha: 1)))
                        }
                    }
                .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
                .alert("Cannot Save Event", isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                } message: {
                    Text("The start date must be before the end date.")
                }
                .navigationTitle("Filter")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                }).foregroundColor(.primary), trailing: Button(action: {
                    if startDate <= endDate {
                        startDate = sDate
                        endDate = eDate
                        selectedSort = selectSort
                        if startDate != defaultStartDate || endDate != defaultEndDate || selectedSort != 0 {
                            isOnFilter = true
                        } else {
                            isOnFilter = false
                        }
                        dismiss()
                    } else {
                        showingAlert = true
                    }
                }, label: {
                    Text("Done")
                }).foregroundColor(.primary)
                )
            }
        }
    }

func dateToEMMMdyyyy(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    if Locale.current.language.languageCode?.identifier == "ja" {
        dateFormatter.dateFormat = "yyyy年MMMd日(EEE)"
    } else {
        dateFormatter.dateFormat = "E, MMM d, yyyy"
    }
    return dateFormatter.string(from: date)
}
