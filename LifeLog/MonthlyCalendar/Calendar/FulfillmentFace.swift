//
//  FulfillmentFace.swift
//  LifeLog
//
//  Created by Genki on 12/22/23.
//

import SwiftUI
import CoreData
import HorizonCalendar

struct FulfillmentFace: View {
    let items: FetchedResults<DateItem>
    let circleColor: Color
    let numberColor: Color
    let day: DayComponents
    var body: some View {
        VStack(spacing: 2) {
            Divider()
            ZStack(alignment: .center) {
                Circle().foregroundColor(circleColor)
                    .frame(width: 20, height: 20)
                Text("\(day.day)")
                    .foregroundColor(numberColor)
                    .font(.system(size: 12))
            }
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
                    }
                }
            }
            Spacer()
        }.frame(height: 110)
    }
}
