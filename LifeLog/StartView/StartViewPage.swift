//
//  StartViewPage.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import SwiftUI

struct StartViewPage: View {
    var page: Page
    var body: some View {
        VStack(spacing: 10) {
            Image("\(page.imageUrl)")
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.9)
            Text(page.name)
                .font(.title)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
            Text(page.description)
                .font(.subheadline)
                .frame(width: UIScreen.main.bounds.width * 0.8)
        }.preferredColorScheme(.light)
    }
}

struct StartViewPage_Previews: PreviewProvider {
    static var previews: some View {
        StartViewPage(page: Page.samplePage)
    }
}
