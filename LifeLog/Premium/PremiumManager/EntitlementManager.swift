//
//  EntitlementManager.swift
//  LifeLog
//
//  Created by Genki on 12/10/23.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "storekit")!

    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
