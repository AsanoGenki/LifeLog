//
//  ResultView.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI
import ConfettiSwiftUI

struct ResultView: View {
    @State private var counter = 0
    @State private var showNotificationAllow = false
    @State private var notificationAllow = false
    @State private var startDate: Date = Date()
    @Binding var title: String
    @Binding var detail: String
    @Binding var fullfilment: Int
    @Binding var endDate: Date
    @AppStorage("showStartView") var showStartView = true
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button {
                    if !notificationAllow {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showNotificationAllow = true
                        }
                    } else {
                        showStartView = false
                    }
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity, maxHeight: 55)
                        .background(Color.black.opacity(0.8).cornerRadius(10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            }
            VStack(spacing: 20) {
                Button {
                    counter += 1
                } label: {
                    Text("🎉Congratulations!\nIt was recorded successfully!")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                }
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(weekDayToYear(endDate))
                                .font(.title3)
                            Text("\(timeString(date: startDate)) ~ \(timeString(date: endDate))")
                                .font(.system(size: 18))
                        }
                        Spacer()
                        HStack {
                            returnFace(adequancy: fullfilment)
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text("\(fullfilment)")
                                .font(.system(size: 20))
                        }
                    }
                    HStack {
                        Rectangle()
                            .frame(width: 4, height: 26)
                            .cornerRadius(100)
                            .foregroundColor(.purple)
                        Text(title)
                            .font(.system(size: 24))
                        Spacer()
                    }.padding(.horizontal, 3)
                    HStack(alignment: .top, spacing: 2) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 10))
                        Text(detail)
                            .font(.system(size: 11))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            VStack {
                Spacer()
                Button {
                    counter += 1
                } label: {
                    Text("")
                        .font(.system(size: 24))
                        .foregroundStyle(.black)
                }.confettiCannon(counter: $counter, repetitions: 3, repetitionInterval: 0.7)
                Spacer()
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            startDate = Calendar.current.date(byAdding: .hour, value: -1, to: endDate)!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                counter += 1
            }
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    notificationAllow = true
                } else {
                    notificationAllow = false
                }
            }
        }
        .fullScreenCover(isPresented: $showNotificationAllow) {
            if !notificationAllow {
                NotificationAllow()
            } else {
                ContentView()
            }
        }
    }
}
