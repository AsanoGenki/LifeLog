//
//  StartView.swift
//  LifeLog
//
//  Created by Genki on 12/25/23.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Image("writtingBear")
                        .resizable()
                        .scaledToFit()
                }.ignoresSafeArea()
                VStack {
                    Spacer()
                    if Locale.current.language.languageCode?.identifier != "ja" {
                        Text(" Your Time, In Your Hands ")
                            .font(.custom("Caveat-SemiBold", size: 30))
                            .foregroundStyle(.black)
                    } else {
                        Text(" あなたの人生を変える\n最後の時間アプリ ")
                            .font(.system(size: 24))
                            .fontWeight(.medium)
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                    }
                    Text(" LifeLog ")
                        .frame(maxWidth: .infinity)
                        .font(.custom("Caveat-SemiBold", size: 100))
                        .foregroundStyle(.black)
                    Spacer()
                    Spacer()
                    NavigationLink(destination: IntroductionView()) {
                        Text("startViewStart")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(Color.black.opacity(0.8).cornerRadius(10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

#Preview {
    StartView()
}
