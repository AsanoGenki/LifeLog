//
//  PageModel.swift
//  LifeLog
//
//  Created by Genki on 12/26/23.
//

import Foundation
import SwiftUI

struct Page: Identifiable, Equatable {
    let id = UUID()
    var name: LocalizedStringKey
    var description: LocalizedStringKey
    var imageUrl: String
    var tag: Int
    static var samplePage = Page(
        name: "Title Example",
        description: "This is a sample description for the purpose of debugging",
        imageUrl: "brain",
        tag: 0)
    static var samplePages: [Page] = [
        Page(name: LocalizedStringKey("What's LifeLog?"),
             description: LocalizedStringKey(
                ["LifeLog is an app that helps you live a fulfilling life ",
                 "by recording your activity time and satisfaction level."].joined()),
             imageUrl: "lifelogIcon", tag: 0),
        Page(name: "Find the best way to use your time!",
             description: LocalizedStringKey(
                ["With LifeLog, you can enrich your life by discovering ",
                 "‘activities that make you feel satisfied’ and ",
                 "‘activities and times when you tend to waste time’ from past data."].joined()),
             imageUrl: "relax", tag: 1),
        Page(name: LocalizedStringKey("Based on scientific evidence"),
             description: LocalizedStringKey(
                ["LifeLog users experience an average productivity ",
                 "increase of 25% and a 30% boost in happiness."].joined()),
             imageUrl: brainImage(), tag: 2),
        Page(name: LocalizedStringKey("Data is stored in iCloud"),
             description: LocalizedStringKey(
                ["Your data is stored in iCloud, so there's no need to sign up. ",
                 "If you want to share data to other devices, please manage them with the same iCloud account. ",
                 "(This may change in the future)"].joined()), imageUrl: "icloud", tag: 3)
    ]
}

private func brainImage() -> String {
    if Locale.current.language.languageCode?.identifier == "ja" {
        return "brainJapan"
    } else {
        return "brain"
    }
}
