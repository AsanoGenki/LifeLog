//
//  AppBlockModel.swift
//  LifeLog
//
//  Created by Genki on 1/23/24.
//

import SwiftUI
import FamilyControls
import ManagedSettings

class AppBlockModel: ObservableObject {
    @AppStorage("blockAppSelecton") var blockAppSelecton = FamilyActivitySelection()
    func blockApp() {
        ManagedSettingsStore(
            named: ManagedSettingsStore.Name("AppBlockTimer")).shield.applications
        = blockAppSelecton.applicationTokens
    }
    func unBlockApp() {
        ManagedSettingsStore(named: ManagedSettingsStore.Name("AppBlockTimer")).clearAllSettings()
    }
    func denyAppRemoval() {
        ManagedSettingsStore(named: ManagedSettingsStore.Name("AppBlockTimer")).application.denyAppRemoval = true
    }
    func undenyAppRemoval() {
        ManagedSettingsStore(named: ManagedSettingsStore.Name("AppBlockTimer")).application.denyAppRemoval = false
    }
}

extension FamilyActivitySelection: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
