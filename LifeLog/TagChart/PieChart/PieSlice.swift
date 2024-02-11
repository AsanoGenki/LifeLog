//
//  PieSliceView.swift
//  LifeLog
//
//  Created by Genki on 1/20/24.
//

import SwiftUI

struct PieSlice: View {
    var pieSliceData: PieSliceData
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let path = Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    path.move(
                        to: CGPoint(
                            x: width * 0.5,
                            y: height * 0.5
                        )
                    )
                    path.addArc(center: CGPoint(x: width * 0.5, y: height * 0.5),
                                radius: width * 0.5,
                                startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                                endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                                clockwise: false)
                }
                path.fill(pieSliceData.color)
                if pieSliceData.percentage > 2.0 {
                    Text(SlicePieText().processText(pieSliceData.text))
                        .position(
                            x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(self.midRadians)),
                            y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(self.midRadians))
                        )
                        .foregroundColor(Color.white)
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieSlice_Previews: PreviewProvider {
    static var previews: some View {
        PieSlice(
            pieSliceData: PieSliceData(
                startAngle: Angle(degrees: 0.0),
                endAngle: Angle(degrees: 120.0),
                text: "30%",
                color: Color.black,
                percentage: 40.0
            )
        )
    }
}
