//
//  PremiumAdsView.swift
//  LifeLog
//
//  Created by Genki on 12/22/23.
//

import SwiftUI

struct PremiumAdsView: View {
    var body: some View {
        ZStack {
           Color("adsBackground")
                .frame(height: 60)
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color("gptPurple"))
                VStack(spacing: 2) {
                    HStack(spacing: 5) {
                        Text("Try LifeLog Premium")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(Color("adsTextColor"))
                        Spacer()
                    }
                    HStack {
                        Text("No Ads, Unlimited Chart, Image capacity...")
                            .font(.system(size: 11))
                            .foregroundColor(Color("adsTextColor"))
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                Spacer()
                Text("Get")
                    .font(.system(size: 16))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 7)
                    .fontWeight(.semibold)
                    .background(Color("gptPurple").cornerRadius(100))
                    .foregroundColor(.white)
            }
            .padding(8)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    PremiumAdsView()
}
