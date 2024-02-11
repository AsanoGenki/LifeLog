//
//  PremiumViewList.swift
//  LifeLog
//
//  Created by Genki on 11/29/23.
//

import SwiftUI

struct CircleCrossItem: View {
    let title: LocalizedStringKey
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(title)
            Spacer()
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
           Image(systemName: "xmark")
                .frame(width: 80, height: 50)
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .background(Color.gray.opacity(0.1))
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
            Image(systemName: "circle")
                .frame(width: 80, height: 50)
                .foregroundColor(Color("gptPurple"))
                .fontWeight(.bold)
                .background(Color("gptPurple").opacity(0.1))
        }
        Line()
            .stroke(style: .init(dash: [4, 3]))
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .frame(height: 0.5)
    }
}
struct LastCircleCrossItem: View {
    let title: LocalizedStringKey
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(title)
                .multilineTextAlignment(.center)
            Spacer()
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
            Image(systemName: "xmark")
                .frame(width: 80, height: 50)
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .background(Color.gray.opacity(0.1))
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
            Image(systemName: "circle")
                .frame(width: 80, height: 50)
                .foregroundColor(Color("gptPurple"))
                .fontWeight(.bold)
                .background(Color("gptPurple").opacity(0.1))
        }
    }
}

struct TextItem: View {
    let title: LocalizedStringKey
    let freeText: String
    let proText: String
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(title)
            Spacer()
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
           Text(freeText)
                .frame(width: 80, height: 50)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .background(Color.gray.opacity(0.1))
            Line2()
                .stroke(style: .init(dash: [4, 3]))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .frame(width: 0.5, height: 50)
            Text(proText)
                .frame(width: 80, height: 50)
                .foregroundColor(Color("gptPurple"))
                .fontWeight(.semibold)
                .background(Color("gptPurple").opacity(0.1))
        }
        Line()
            .stroke(style: .init(dash: [4, 3]))
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .frame(height: 0.5)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct Line2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
