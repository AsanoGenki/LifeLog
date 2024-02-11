//
//  EmotionFaceView.swift
//  LifeLog
//
//  Created by Genki on 1/19/24.
//

import SwiftUI

struct EmotionFaceView: View {
    let items: FetchedResults<DateItem>
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            if let fullfilment = items.first?.adequancy {
                if fullfilment >= 0 && fullfilment <= 100 {
                    returnFace(adequancy: Int(fullfilment))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(fullfilment)")
                        .foregroundColor(.primary)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                } else {
                    Image("noFace")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("-")
                        .foregroundColor(.primary)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                }
            } else {
                Image("noFace")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("-")
                    .foregroundColor(.primary)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
            }
        }
    }
}
