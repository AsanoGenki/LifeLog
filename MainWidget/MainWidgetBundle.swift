//
//  MainWidgetBundle.swift
//  MainWidget
//
//  Created by Genki on 12/27/23.
//

import WidgetKit
import SwiftUI

@main
struct MainWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountDownWidgetLiveActivity()
        CountUpWidgetLiveActivity()
        AddEventWidget()
    }
}
