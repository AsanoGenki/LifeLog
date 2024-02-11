//
//  NotificationAllow.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI

struct NotificationAllow: View {
    @State var showMainView = false
    @AppStorage("showStartView") var showStartView = true
    var body: some View {
        if !showMainView {
            ZStack {
                VStack(spacing: 16) {
                    Image("time")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                    Text("Don't forget to record \nyour daily records!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24))
                        .fontWeight(.heavy)
                        .foregroundColor(.red)
                    if Locale.current.language.languageCode?.identifier == "ja" {
                        Image("notification_jp")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.70)
                    } else {
                        Image("notification")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.70)
                    }
                }.padding(.bottom, 30)
                VStack {
                    Spacer()
                    Button {
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if let error = error {
                                print("Authorization request failed with error: \(error)")
                            } else {
                                if granted {
                                } else {
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showStartView = false
                                    showMainView = true
                                }
                            }
                        }
                    } label: {
                        Text("OK, I got it.")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(Color.red.cornerRadius(10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }
                }
            }.preferredColorScheme(.light)
        }
    }
}
